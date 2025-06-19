-- Обновление пароля администратора (пароль: admin123)
UPDATE admins 
SET password_hash = '$2a$10$rQZ8K9mN2pL4vX7wY1sT3uI6oP8qR0tU2vW3xY4zA5bC6dE7fG8hI9jK0lM1n' 
WHERE username = 'admin'; 