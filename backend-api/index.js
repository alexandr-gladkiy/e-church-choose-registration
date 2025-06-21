require('dotenv').config();
const express = require('express');
const cors = require('cors');
const usersRouter = require('./routes/users');
const adminsRouter = require('./routes/admins');
const registrationSettingsRouter = require('./routes/registrationSettings');

const app = express();

// Логирование запросов
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);
  console.log('Request Body:', req.body);
  next();
});

// CORS middleware
const allowedOrigins = [
  'http://localhost:5173', 
  'http://localhost:5174',
  'https://localhost:5173',
  'https://localhost:5174'
];

// Добавляем поддомены из переменных окружения
if (process.env.DOMAIN) {
  const domain = process.env.DOMAIN.replace('https://', '').replace('http://', '');
  const adminDomain = process.env.ADMIN_DOMAIN?.replace('https://', '').replace('http://', '') || `admin.${domain}`;
  
  allowedOrigins.push(
    `https://${domain}`,
    `https://${adminDomain}`,
    `http://${domain}`,
    `http://${adminDomain}`
  );
}

app.use(cors({
  origin: function (origin, callback) {
    // Разрешаем запросы без origin (например, от мобильных приложений)
    if (!origin) return callback(null, true);
    
    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      console.log('CORS blocked origin:', origin);
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));

// Body parser
app.use(express.json());

// Маршруты
app.use('/api/users', usersRouter);
app.use('/api/admins', adminsRouter);
app.use('/api/registration-settings', registrationSettingsRouter);

// Обработка ошибок
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
});

// Обработка 404
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.url} not found`
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}`);
}); 