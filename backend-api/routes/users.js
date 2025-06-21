const express = require('express');
const pool = require('../db');
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
      'SELECT * FROM users WHERE telegram_id = $1 AND cancelled_at IS NULL',
      [telegram_id]
    );
    
    if (existingUser.rows.length > 0) {
      return res.status(400).json({ 
        error: 'Пользователь уже зарегистрирован',
        existingUser: existingUser.rows[0]
      });
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

module.exports = router; 