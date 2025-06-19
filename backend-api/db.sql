-- Таблица участников мероприятия
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    city VARCHAR(100) NOT NULL,
    church_name VARCHAR(255) NOT NULL,
    need_accommodation BOOLEAN DEFAULT FALSE,
    comments TEXT,
    telegram_id BIGINT NOT NULL UNIQUE,
    telegram_username VARCHAR(100) NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cancelled_at TIMESTAMP
);

-- Таблица администраторов
CREATE TABLE IF NOT EXISTS admins (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица настроек регистрации
CREATE TABLE IF NOT EXISTS registration_settings (
    id SERIAL PRIMARY KEY,
    is_open BOOLEAN DEFAULT TRUE,
    registration_start TIMESTAMP,
    registration_deadline TIMESTAMP
);

-- Вставка дефолтных настроек (одна строка)
INSERT INTO registration_settings (is_open, registration_start, registration_deadline)
VALUES (TRUE, CURRENT_TIMESTAMP, NULL)
ON CONFLICT DO NOTHING; 