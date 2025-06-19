-- Создание администратора (пароль: admin123)
INSERT INTO admins (username, password_hash) 
VALUES ('admin', '$2b$10$9PzCt6kj3RZMnHtT3AXxZuljAKgnFzx.KPEpx22rfuHporxeYR16e')
ON CONFLICT (username) DO UPDATE SET 
  password_hash = EXCLUDED.password_hash; 