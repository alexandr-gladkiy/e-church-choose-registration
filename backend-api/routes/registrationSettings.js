const express = require('express');
const pool = require('../db');
const jwt = require('jsonwebtoken');
const router = express.Router();

function auth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ error: 'Нет токена' });
  const token = authHeader.split(' ')[1];
  try {
    req.admin = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ error: 'Неверный токен' });
  }
}

// Получить настройки
router.get('/', async (req, res) => {
  const result = await pool.query('SELECT * FROM registration_settings LIMIT 1');
  res.json(result.rows[0]);
});

// Изменить настройки (только для админа)
router.put('/', auth, async (req, res) => {
  const { is_open, registration_start, registration_deadline } = req.body;
  const result = await pool.query(
    `UPDATE registration_settings SET is_open = $1, registration_start = $2, registration_deadline = $3 WHERE id = 1 RETURNING *`,
    [is_open, registration_start, registration_deadline]
  );
  res.json({ success: true, settings: result.rows[0] });
});

module.exports = router; 