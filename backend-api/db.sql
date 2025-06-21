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

-- Автоматическое добавление администратора admin/admin
INSERT INTO admins (username, password_hash)
VALUES ('admin', '$2b$10$9TasZf/LzTB9Hh./0LWS4e1Ny5eO3S/XR3OtMq/FzL.SPg9TXY3zu')
ON CONFLICT (username) DO NOTHING;

-- Таблица настроек регистрации
CREATE TABLE IF NOT EXISTS registration_settings (
    id SERIAL PRIMARY KEY,
    is_open BOOLEAN DEFAULT TRUE,
    registration_start TIMESTAMP,
    registration_deadline TIMESTAMP,
    max_participants INTEGER DEFAULT NULL,
    browser_access_enabled BOOLEAN DEFAULT FALSE
);

-- Вставка дефолтных настроек (одна строка)
INSERT INTO registration_settings (is_open, registration_start, registration_deadline, max_participants, browser_access_enabled)
VALUES (TRUE, CURRENT_TIMESTAMP, NULL, NULL, FALSE)
ON CONFLICT DO NOTHING;

-- Добавляем поле max_participants если его нет (для существующих баз)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'registration_settings' AND column_name = 'max_participants') THEN
        ALTER TABLE registration_settings ADD COLUMN max_participants INTEGER DEFAULT NULL;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'registration_settings' AND column_name = 'browser_access_enabled') THEN
        ALTER TABLE registration_settings ADD COLUMN browser_access_enabled BOOLEAN DEFAULT FALSE;
    END IF;
END $$; 