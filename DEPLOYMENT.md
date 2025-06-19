# Инструкция по развёртыванию Event Registration

## Предварительные требования

### 1. Сервер
- Ubuntu 20.04+ или Debian 11+
- Минимум 2GB RAM
- 20GB свободного места
- Доступ по SSH

### 2. Домен (опционально, но рекомендуется)
- Зарегистрированный домен
- Настроенные DNS записи (A-запись на IP сервера)

### 3. Telegram Bot Token
- Создайте бота через [@BotFather](https://t.me/BotFather)
- Получите токен в формате: `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz`

## Пошаговая инструкция развёртывания

### Шаг 1: Подготовка сервера

1. **Подключитесь к серверу по SSH:**
   ```bash
   ssh username@your-server-ip
   ```

2. **Создайте пользователя для приложения (рекомендуется):**
   ```bash
   sudo adduser eventuser
   sudo usermod -aG sudo eventuser
   su - eventuser
   ```

### Шаг 2: Загрузка скрипта развёртывания

1. **Скачайте скрипт развёртывания:**
   ```bash
   wget https://raw.githubusercontent.com/your-username/event-registration/main/deploy.sh
   chmod +x deploy.sh
   ```

2. **Или создайте скрипт вручную:**
   ```bash
   nano deploy.sh
   # Вставьте содержимое скрипта и сохраните (Ctrl+X, Y, Enter)
   chmod +x deploy.sh
   ```

### Шаг 3: Запуск развёртывания

**Базовое развёртывание (localhost):**
```bash
./deploy.sh https://github.com/your-username/event-registration.git YOUR_BOT_TOKEN
```

**Развёртывание с доменом:**
```bash
./deploy.sh https://github.com/your-username/event-registration.git YOUR_BOT_TOKEN yourdomain.com
```

### Шаг 4: Ожидание завершения

Скрипт автоматически выполнит:
- ✅ Обновление системы
- ✅ Установку Docker и Docker Compose
- ✅ Установку nginx
- ✅ Клонирование проекта
- ✅ Настройку переменных окружения
- ✅ Сборку и запуск контейнеров
- ✅ Настройку автозапуска

**Время выполнения:** 10-15 минут

## Проверка развёртывания

### 1. Проверка статуса сервисов
```bash
event-registration-manage status
```

### 2. Проверка логов
```bash
event-registration-manage logs
```

### 3. Проверка доступности
- **Telegram WebApp:** http://your-domain.com (или IP сервера)
- **Admin Panel:** http://your-domain.com/admin
- **API:** http://your-domain.com/api

## Управление приложением

### Команды управления
```bash
# Статус всех сервисов
event-registration-manage status

# Просмотр логов
event-registration-manage logs

# Перезапуск всех сервисов
event-registration-manage restart

# Остановка всех сервисов
event-registration-manage stop

# Запуск всех сервисов
event-registration-manage start

# Обновление приложения
event-registration-manage update
```

### Ручное управление Docker
```bash
cd /opt/event-registration
docker-compose ps
docker-compose logs -f
docker-compose restart
```

## Настройка SSL (HTTPS)

### Автоматическая настройка с Let's Encrypt

1. **Установите Certbot:**
   ```bash
   sudo apt-get install certbot python3-certbot-nginx
   ```

2. **Получите SSL сертификат:**
   ```bash
   sudo certbot --nginx -d yourdomain.com
   ```

3. **Настройте автообновление:**
   ```bash
   sudo crontab -e
   # Добавьте строку:
   0 12 * * * /usr/bin/certbot renew --quiet
   ```

## Настройка Telegram Bot

### 1. Настройка WebApp URL
В Telegram Bot API установите WebApp URL:
```
https://yourdomain.com
```

### 2. Тестирование бота
1. Найдите вашего бота в Telegram
2. Отправьте команду `/start`
3. Нажмите кнопку "Открыть регистрацию"
4. Убедитесь, что WebApp открывается корректно

## Мониторинг и обслуживание

### 1. Мониторинг ресурсов
```bash
# Использование диска
df -h

# Использование памяти
free -h

# Использование CPU
htop

# Логи системы
sudo journalctl -f
```

### 2. Резервное копирование
```bash
# Создание бэкапа базы данных
docker-compose exec postgres pg_dump -U postgres event_registration > backup.sql

# Восстановление из бэкапа
docker-compose exec -T postgres psql -U postgres event_registration < backup.sql
```

### 3. Обновление приложения
```bash
# Автоматическое обновление
event-registration-manage update

# Ручное обновление
cd /opt/event-registration
git pull origin main
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Устранение неполадок

### Проблемы с доступом
```bash
# Проверка портов
sudo netstat -tlnp

# Проверка nginx
sudo nginx -t
sudo systemctl status nginx

# Проверка Docker
sudo systemctl status docker
```

### Проблемы с ботом
```bash
# Проверка логов бота
docker-compose logs telegram-bot

# Проверка токена
cat /opt/event-registration/.env
```

### Проблемы с WebApp
```bash
# Проверка логов WebApp
docker-compose logs telegram-app

# Проверка доступности
curl -I http://localhost:5174
```

## Безопасность

### 1. Firewall
```bash
# Проверка статуса UFW
sudo ufw status

# Открытие дополнительных портов (если нужно)
sudo ufw allow 8080/tcp
```

### 2. Обновления безопасности
```bash
# Автоматические обновления безопасности
sudo apt-get install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 3. Мониторинг безопасности
```bash
# Проверка открытых портов
sudo nmap localhost

# Проверка процессов
ps aux | grep -E "(docker|nginx|node)"
```

## Контакты и поддержка

При возникновении проблем:
1. Проверьте логи: `event-registration-manage logs`
2. Проверьте статус: `event-registration-manage status`
3. Создайте issue в репозитории проекта

---

**Успешного развёртывания! 🚀** 