const express = require('express');
const pool = require('../db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const router = express.Router();

// Middleware для проверки JWT
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

// Вход администратора
router.post('/login', async (req, res) => {
  console.log('Попытка входа администратора:', req.body);
  const { username, password } = req.body;
  
  if (!username || !password) {
    console.log('Отсутствуют username или password');
    return res.status(400).json({ error: 'Необходимы логин и пароль' });
  }
  
  try {
    const result = await pool.query('SELECT * FROM admins WHERE username = $1', [username]);
    if (!result.rows.length) {
      console.log('Пользователь не найден:', username);
      return res.status(401).json({ error: 'Неверный логин или пароль' });
    }
    
    const admin = result.rows[0];
    const valid = await bcrypt.compare(password, admin.password_hash);
    if (!valid) {
      console.log('Неверный пароль для пользователя:', username);
      return res.status(401).json({ error: 'Неверный логин или пароль' });
    }
    
    const token = jwt.sign({ id: admin.id, username: admin.username }, process.env.JWT_SECRET, { expiresIn: '12h' });
    console.log('Успешный вход для пользователя:', username);
    res.json({ success: true, token });
  } catch (error) {
    console.error('Ошибка при входе:', error);
    res.status(500).json({ error: 'Ошибка сервера' });
  }
});

// Получить текущего админа
router.get('/me', auth, async (req, res) => {
  const result = await pool.query('SELECT id, username, created_at FROM admins WHERE id = $1', [req.admin.id]);
  res.json(result.rows[0]);
});

// Смена пароля
router.post('/change-password', auth, async (req, res) => {
  const { oldPassword, newPassword } = req.body;
  const result = await pool.query('SELECT * FROM admins WHERE id = $1', [req.admin.id]);
  const admin = result.rows[0];
  const valid = await bcrypt.compare(oldPassword, admin.password_hash);
  if (!valid) return res.status(400).json({ error: 'Старый пароль неверен' });
  const hash = await bcrypt.hash(newPassword, 10);
  await pool.query('UPDATE admins SET password_hash = $1 WHERE id = $2', [hash, admin.id]);
  res.json({ success: true });
});

module.exports = router; 