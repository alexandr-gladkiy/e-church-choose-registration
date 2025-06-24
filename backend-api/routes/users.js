const express = require('express');
const pool = require('../db');
const PDFDocument = require('pdfkit');
const router = express.Router();

// Получить всех участников
router.get('/', async (req, res) => {
  const { telegramId } = req.query;
  
  if (telegramId) {
    // Поиск пользователя по telegramId
    const result = await pool.query('SELECT * FROM users WHERE telegram_id = $1 ORDER BY registration_date DESC', [telegramId]);
    res.json(result.rows);
  } else {
    // Получить всех пользователей
    const result = await pool.query('SELECT * FROM users ORDER BY registration_date DESC');
    res.json(result.rows);
  }
});

// Получить участника по id
router.get('/:id', async (req, res) => {
  const { id } = req.params;
  const result = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
  if (result.rows.length === 0) return res.status(404).json({ error: 'Not found' });
  res.json(result.rows[0]);
});

// Добавить участника
router.post('/', async (req, res) => {
  console.log('Получен POST запрос на /api/users:', req.body);
  const { full_name, email, phone, city, church_name, need_accommodation, comments, telegram_id, telegram_username } = req.body;
  
  if (!full_name || !city || !church_name || !telegram_id || !telegram_username) {
    console.log('Ошибка валидации:', { full_name, city, church_name, telegram_id, telegram_username });
    return res.status(400).json({ error: 'Обязательные поля: ФИО, город, церковь, telegramId, telegramUsername' });
  }
  
  try {
    // Проверяем настройки регистрации
    const settingsResult = await pool.query('SELECT * FROM registration_settings LIMIT 1');
    const settings = settingsResult.rows[0];
    
    if (!settings.is_open) {
      return res.status(400).json({ error: 'Регистрация закрыта' });
    }
    
    // Проверяем лимит участников
    if (settings.max_participants) {
      const participantsResult = await pool.query(
        'SELECT COUNT(*) as count FROM users WHERE cancelled_at IS NULL'
      );
      const activeParticipants = parseInt(participantsResult.rows[0].count);
      
      if (activeParticipants >= settings.max_participants) {
        return res.status(400).json({ 
          error: 'Достигнут лимит участников',
          max_participants: settings.max_participants,
          active_participants: activeParticipants
        });
      }
    }
    
    // Проверяем, не зарегистрирован ли уже пользователь
    const existingUser = await pool.query(
      'SELECT * FROM users WHERE telegram_id = $1',
      [telegram_id]
    );
    
    if (existingUser.rows.length > 0) {
      const user = existingUser.rows[0];
      
      // Если пользователь уже активен (не отменен)
      if (!user.cancelled_at) {
        return res.status(400).json({ 
          error: 'Пользователь уже зарегистрирован',
          existingUser: user
        });
      }
      
      // Если пользователь отменен - обновляем его данные и снимаем отмену
      console.log('Обновляем отмененного пользователя:', user.id);
      const updateResult = await pool.query(
        `UPDATE users SET 
          full_name = $1, 
          email = $2, 
          phone = $3, 
          city = $4, 
          church_name = $5, 
          need_accommodation = $6, 
          comments = $7, 
          telegram_username = $8,
          cancelled_at = NULL,
          registration_date = NOW()
         WHERE id = $9 RETURNING *`,
        [full_name, email, phone, city, church_name, need_accommodation ?? false, comments, telegram_username, user.id]
      );
      
      console.log('Пользователь успешно обновлен и активирован:', updateResult.rows[0]);
      res.json({ success: true, user: updateResult.rows[0], reactivated: true });
      return;
    }
    
    const result = await pool.query(
      `INSERT INTO users (full_name, email, phone, city, church_name, need_accommodation, comments, telegram_id, telegram_username)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING *`,
      [full_name, email, phone, city, church_name, need_accommodation ?? false, comments, telegram_id, telegram_username]
    );
    console.log('Пользователь успешно добавлен:', result.rows[0]);
    res.json({ success: true, user: result.rows[0] });
  } catch (e) {
    console.error('Ошибка при добавлении пользователя:', e);
    if (e.code === '23505') {
      return res.status(400).json({ error: 'Пользователь с таким telegramId уже существует' });
    }
    res.status(500).json({ error: 'Ошибка добавления: ' + e.message });
  }
});

// Изменить участника
router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const { full_name, email, phone, city, church_name, need_accommodation, comments, telegram_id, telegram_username } = req.body;
  try {
    const result = await pool.query(
      `UPDATE users SET full_name=$1, email=$2, phone=$3, city=$4, church_name=$5, need_accommodation=$6, comments=$7, telegram_id=$8, telegram_username=$9 WHERE id=$10 RETURNING *`,
      [full_name, email, phone, city, church_name, need_accommodation ?? false, comments, telegram_id, telegram_username, id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Not found' });
    res.json({ success: true, user: result.rows[0] });
  } catch (e) {
    if (e.code === '23505') return res.status(400).json({ error: 'Пользователь с таким telegramId уже существует' });
    res.status(500).json({ error: 'Ошибка обновления' });
  }
});

// Удалить участника
router.delete('/:id', async (req, res) => {
  const { id } = req.params;
  await pool.query('DELETE FROM users WHERE id = $1', [id]);
  res.json({ success: true });
});

// Отменить регистрацию
router.post('/:id/cancel', async (req, res) => {
  const { id } = req.params;
  await pool.query('UPDATE users SET cancelled_at = NOW() WHERE id = $1', [id]);
  res.json({ success: true });
});

// Экспорт в CSV
router.get('/export/csv', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users ORDER BY registration_date DESC');
    const users = result.rows;
    
    // Создаем CSV заголовки
    const headers = [
      'ID',
      'ФИО',
      'Email',
      'Телефон',
      'Город',
      'Церковь',
      'Нужно жилье',
      'Telegram ID',
      'Telegram Username',
      'Комментарии',
      'Дата регистрации',
      'Отменен'
    ];
    
    // Создаем CSV строки
    const csvRows = [headers.join(',')];
    
    users.forEach(user => {
      const row = [
        user.id,
        `"${(user.full_name || '').replace(/"/g, '""')}"`,
        `"${(user.email || '').replace(/"/g, '""')}"`,
        `"${(user.phone || '').replace(/"/g, '""')}"`,
        `"${(user.city || '').replace(/"/g, '""')}"`,
        `"${(user.church_name || '').replace(/"/g, '""')}"`,
        user.need_accommodation ? 'Да' : 'Нет',
        user.telegram_id || '',
        `"${(user.telegram_username || '').replace(/"/g, '""')}"`,
        `"${(user.comments || '').replace(/"/g, '""')}"`,
        user.registration_date ? new Date(user.registration_date).toLocaleDateString('ru-RU') : '',
        user.cancelled_at ? 'Да' : 'Нет'
      ];
      csvRows.push(row.join(','));
    });
    
    const csvContent = csvRows.join('\n');
    
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', 'attachment; filename="registrations.csv"');
    res.send('\ufeff' + csvContent); // BOM для корректного отображения кириллицы в Excel
  } catch (error) {
    console.error('Ошибка экспорта CSV:', error);
    res.status(500).json({ error: 'Ошибка экспорта' });
  }
});

// Экспорт активных пользователей в PDF
router.get('/export/pdf', async (req, res) => {
  try {
    // Получаем только активных пользователей (не отмененных)
    const result = await pool.query('SELECT * FROM users WHERE cancelled_at IS NULL ORDER BY registration_date DESC');
    const users = result.rows;
    
    // Создаем PDF документ в альбомной ориентации
    const doc = new PDFDocument({ 
      size: 'A4',
      layout: 'landscape',
      margins: {
        top: 30,
        bottom: 30,
        left: 30,
        right: 30
      }
    });
    
    // Устанавливаем заголовки для скачивания
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', 'attachment; filename="active_registrations.pdf"');
    
    // Подключаем поток к ответу
    doc.pipe(res);
    
    // Функция для безопасного отображения текста
    const safeText = (text) => {
      if (!text) return '';
      // Преобразуем в строку и обрезаем длину
      return String(text).substring(0, 30);
    };
    
    // Добавляем заголовок
    doc.fontSize(16)
       .font('Helvetica-Bold')
       .text('Список зарегистрированных участников', { align: 'center' });
    
    doc.moveDown(0.5);
    doc.fontSize(10)
       .font('Helvetica')
       .text(`Дата экспорта: ${new Date().toLocaleDateString('ru-RU')}`, { align: 'center' });
    doc.moveDown(0.5);
    doc.text(`Всего участников: ${users.length}`, { align: 'center' });
    doc.moveDown(1);
    
    if (users.length === 0) {
      doc.fontSize(12)
         .text('Нет активных зарегистрированных участников', { align: 'center' });
    } else {
      // Создаем таблицу со всеми полями
      const tableTop = doc.y;
      const tableLeft = 30;
      const tableWidth = 750; // Больше места в альбомной ориентации
      
      // Определяем ширину колонок
      const colWidths = [30, 120, 80, 80, 80, 100, 50, 80, 80, 70]; // ID, ФИО, Email, Телефон, Город, Церковь, Жилье, Telegram ID, Username, Дата
      const headers = ['№', 'ФИО', 'Email', 'Телефон', 'Город', 'Церковь', 'Жилье', 'Telegram ID', 'Username', 'Дата'];
      const rowHeight = 18;
      
      // Заголовки таблицы
      doc.fontSize(8).font('Helvetica-Bold');
      
      headers.forEach((header, i) => {
        const x = tableLeft + colWidths.slice(0, i).reduce((sum, width) => sum + width, 0);
        const width = colWidths[i];
        doc.rect(x, tableTop, width, rowHeight).stroke();
        doc.text(header, x + 2, tableTop + 2, { width: width - 4 });
      });
      
      // Данные таблицы
      doc.fontSize(7).font('Helvetica');
      users.forEach((user, index) => {
        const y = tableTop + ((index + 1) * rowHeight);
        
        // Проверяем, не выходит ли таблица за пределы страницы
        if (y + rowHeight > doc.page.height - 50) {
          doc.addPage();
          doc.fontSize(12).font('Helvetica-Bold');
          doc.text('Список зарегистрированных участников (продолжение)', { align: 'center' });
          doc.moveDown(1);
          return;
        }
        
        const rowData = [
          (index + 1).toString(),
          safeText(user.full_name),
          safeText(user.email),
          safeText(user.phone),
          safeText(user.city),
          safeText(user.church_name),
          user.need_accommodation ? 'Да' : 'Нет',
          safeText(user.telegram_id),
          safeText(user.telegram_username),
          user.registration_date ? new Date(user.registration_date).toLocaleDateString('ru-RU') : ''
        ];
        
        rowData.forEach((cell, i) => {
          const x = tableLeft + colWidths.slice(0, i).reduce((sum, width) => sum + width, 0);
          const width = colWidths[i];
          doc.rect(x, y, width, rowHeight).stroke();
          doc.text(cell, x + 2, y + 2, { width: width - 4 });
        });
      });
      
      // Добавляем информацию о комментариях на отдельной странице
      if (users.some(u => u.comments)) {
        doc.addPage();
        doc.fontSize(14).font('Helvetica-Bold');
        doc.text('Комментарии участников', { align: 'center' });
        doc.moveDown(1);
        
        doc.fontSize(10).font('Helvetica');
        users.forEach((user, index) => {
          if (user.comments) {
            doc.fontSize(10).font('Helvetica-Bold');
            doc.text(`${index + 1}. ${safeText(user.full_name) || 'Без имени'}:`);
            doc.fontSize(9).font('Helvetica');
            doc.text(safeText(user.comments), { indent: 20, width: 750 });
            doc.moveDown(0.5);
          }
        });
      }
    }
    
    // Завершаем документ
    doc.end();
    
  } catch (error) {
    console.error('Ошибка экспорта PDF:', error);
    res.status(500).json({ error: 'Ошибка экспорта PDF' });
  }
});

module.exports = router; 