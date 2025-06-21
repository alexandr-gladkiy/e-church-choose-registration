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
  try {
    const result = await pool.query('SELECT * FROM registration_settings LIMIT 1');
    
    // Получаем количество активных участников
    const participantsResult = await pool.query(
      'SELECT COUNT(*) as count FROM users WHERE cancelled_at IS NULL'
    );
    
    const settings = result.rows[0];
    const activeParticipants = parseInt(participantsResult.rows[0].count);
    
    // Добавляем информацию о доступных местах
    const availableSpots = settings.max_participants ? 
      Math.max(0, settings.max_participants - activeParticipants) : null;
    
    res.json({
      ...settings,
      active_participants: activeParticipants,
      available_spots: availableSpots,
      is_full: settings.max_participants ? activeParticipants >= settings.max_participants : false
    });
  } catch (error) {
    console.error('Ошибка при получении настроек:', error);
    res.status(500).json({ error: 'Внутренняя ошибка сервера' });
  }
});

// Изменить настройки (только для админа)
router.put('/', auth, async (req, res) => {
  try {
    const { 
      is_open, 
      registration_start, 
      registration_deadline, 
      max_participants,
      browser_access_enabled 
    } = req.body;
    
    const result = await pool.query(
      `UPDATE registration_settings 
       SET is_open = $1, 
           registration_start = $2, 
           registration_deadline = $3,
           max_participants = $4,
           browser_access_enabled = $5
       WHERE id = 1 
       RETURNING *`,
      [is_open, registration_start, registration_deadline, max_participants, browser_access_enabled]
    );
    
    // Получаем обновленную информацию о участниках
    const participantsResult = await pool.query(
      'SELECT COUNT(*) as count FROM users WHERE cancelled_at IS NULL'
    );
    
    const settings = result.rows[0];
    const activeParticipants = parseInt(participantsResult.rows[0].count);
    const availableSpots = settings.max_participants ? 
      Math.max(0, settings.max_participants - activeParticipants) : null;
    
    res.json({ 
      success: true, 
      settings: {
        ...settings,
        active_participants: activeParticipants,
        available_spots: availableSpots,
        is_full: settings.max_participants ? activeParticipants >= settings.max_participants : false
      }
    });
  } catch (error) {
    console.error('Ошибка при обновлении настроек:', error);
    res.status(500).json({ error: 'Внутренняя ошибка сервера' });
  }
});

module.exports = router; 