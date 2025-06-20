# 🚀 Финальная инструкция по развёртыванию Event Registration

## ✅ Исправленные проблемы

- **package-lock.json not found** - исправлено в Dockerfile
- **UFW command not found** - добавлена автоматическая установка
- **Vite not found** - исправлено в Dockerfile
- **Docker cache issues** - добавлена очистка кэша

---

## Быстрое развёртывание (рекомендуется)

### 1. Подключение к серверу
```bash
ssh username@your-server-ip
```

### 2. Скачивание скрипта
```bash
wget https://raw.githubusercontent.com/your-username/event-registration/main/quick-deploy.sh
chmod +x quick-deploy.sh
```

### 3. Запуск развёртывания
```bash
./quick-deploy.sh https://github.com/your-username/event-registration.git 7487987244:AAGFxvVCBMsndF3Zf3cSX3OKSdpKXbfGR_Y
```

**Результат:**
- Telegram WebApp: `http://YOUR_SERVER_IP:5174`
- Admin Panel: `http://YOUR_SERVER_IP:5173`
- API: `http://YOUR_SERVER_IP:3000`

---

## Полное развёртывание (с доменом)

### 1. Подключение к серверу
```bash
ssh username@your-server-ip
```

### 2. Скачивание скрипта
```bash
wget https://raw.githubusercontent.com/your-username/event-registration/main/deploy.sh
chmod +x deploy.sh
```

### 3. Запуск развёртывания
```bash
./deploy.sh https://github.com/your-username/event-registration.git 7487987244:AAGFxvVCBMsndF3Zf3cSX3OKSdpKXbfGR_Y yourdomain.com
```

**Результат:**
- Telegram WebApp: `https://yourdomain.com`
- Admin Panel: `https://yourdomain.com/admin`
- API: `https://yourdomain.com/api`

---

## Что делают скрипты

### Автоматически устанавливают:
- ✅ Docker и Docker Compose
- ✅ UFW (firewall)
- ✅ nginx (для полного развёртывания)
- ✅ Все зависимости

### Автоматически настраивают:
- ✅ Переменные окружения (.env)
- ✅ Firewall правила
- ✅ Автозапуск сервисов
- ✅ Скрипты управления

### Автоматически запускают:
- ✅ PostgreSQL (база данных)
- ✅ Backend API
- ✅ Admin Panel
- ✅ Telegram WebApp
- ✅ Telegram Bot

---

## Управление после развёртывания

### Команды управления
```bash
# Быстрое развёртывание
event-manage status
event-manage logs
event-manage restart

# Полное развёртывание
event-registration-manage status
event-registration-manage logs
event-registration-manage restart
```

### Ручное управление
```bash
cd /opt/event-registration
docker-compose ps
docker-compose logs -f
docker-compose restart
```

---

## Тестирование

### 1. Telegram Bot
1. Найдите вашего бота в Telegram
2. Отправьте `/start`
3. Нажмите кнопку "Открыть регистрацию"

### 2. WebApp
```bash
# Откройте в браузере
http://YOUR_SERVER_IP:5174
```

### 3. Admin Panel
```bash
# Откройте в браузере
http://YOUR_SERVER_IP:5173

# Логин: admin
# Пароль: admin123
```

---

## Устранение проблем

### Проблемы с UFW
```bash
# Установка UFW
sudo apt-get install ufw -y

# Настройка правил
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 5173/tcp
sudo ufw allow 5174/tcp
sudo ufw allow 3000/tcp
sudo ufw --force enable
```

### Проблемы с Docker
```bash
# Очистка кэша
docker system prune -f

# Пересборка
docker-compose build --no-cache
```

### Проблемы с package-lock.json
```bash
# Пересоздание package-lock.json
cd /opt/event-registration/admin-app
rm package-lock.json
npm install

cd /opt/event-registration/telegram-app
rm package-lock.json
npm install
```

---

## Мониторинг

### Проверка ресурсов
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

### Проверка сервисов
```bash
# Статус всех контейнеров
docker-compose ps

# Логи всех сервисов
docker-compose logs

# Логи конкретного сервиса
docker-compose logs telegram-bot
docker-compose logs telegram-app
docker-compose logs backend-api
```

---

## Резервное копирование

### Создание бэкапа
```bash
# Бэкап базы данных
docker-compose exec postgres pg_dump -U postgres event_registration > backup_$(date +%Y%m%d_%H%M%S).sql

# Бэкап всего проекта
tar -czf event-registration-backup-$(date +%Y%m%d_%H%M%S).tar.gz /opt/event-registration
```

### Восстановление
```bash
# Восстановление базы данных
docker-compose exec -T postgres psql -U postgres event_registration < backup.sql
```

---

## Обновление

### Автоматическое обновление
```bash
# Быстрое развёртывание
event-manage update

# Полное развёртывание
event-registration-manage update
```

### Ручное обновление
```bash
cd /opt/event-registration
git pull origin main
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## Безопасность

### Firewall
```bash
# Проверка статуса UFW
sudo ufw status

# Открытие дополнительных портов
sudo ufw allow 8080/tcp
```

### SSL сертификат
```bash
# Установка Certbot
sudo apt-get install certbot python3-certbot-nginx

# Получение SSL сертификата
sudo certbot --nginx -d yourdomain.com

# Автообновление
sudo crontab -e
# Добавьте строку:
0 12 * * * /usr/bin/certbot renew --quiet
```

---

## Готово! 🎉

После выполнения всех шагов у вас будет полностью работающая система:

- ✅ **Telegram Bot** с вашим токеном
- ✅ **WebApp** для регистрации пользователей
- ✅ **Admin Panel** для управления
- ✅ **API** для обработки данных
- ✅ **База данных** PostgreSQL
- ✅ **Автоматическое управление** сервисами

**Время развёртывания:** 10-15 минут

**Готово к использованию! 🚀** 