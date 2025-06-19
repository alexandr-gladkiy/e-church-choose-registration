const express = require('express');
const pool = require('../db');
const router = express.Router();

// Получить всех участников
router.get('/', async (req, res) => {
  const result = await pool.query('SELECT * FROM users ORDER BY registration_date DESC');
  res.json(result.rows);
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
  const { full_name, email, phone, city, church_name, need_accommodation, comments, telegram_id, telegram_username } = req.body;
  if (!full_name || !city || !church_name || !telegram_id || !telegram_username) {
    return res.status(400).json({ error: 'Обязательные поля: ФИО, город, церковь, telegramId, telegramUsername' });
  }
  try {
    const result = await pool.query(
      `INSERT INTO users (full_name, email, phone, city, church_name, need_accommodation, comments, telegram_id, telegram_username)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING *`,
      [full_name, email, phone, city, church_name, need_accommodation ?? false, comments, telegram_id, telegram_username]
    );
    res.json({ success: true, user: result.rows[0] });
  } catch (e) {
    if (e.code === '23505') return res.status(400).json({ error: 'Пользователь с таким telegramId уже существует' });
    res.status(500).json({ error: 'Ошибка добавления' });
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