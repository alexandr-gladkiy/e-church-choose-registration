# Event Registration - Инструкция по развёртыванию

## Новая конфигурация (один домен)

Проект теперь использует один домен с путями:
- **Telegram WebApp**: `https://choose.su/`
- **Admin Panel**: `https://choose.su/admin`
- **API**: `https://choose.su/api`

## Быстрое развёртывание

### 1. Первоначальный деплой

```bash
./deploy.sh [GITHUB_REPO_URL] [BOT_TOKEN] [DOMAIN]
```

Пример:
```bash
./deploy.sh https://github.com/username/event-registration.git 1234567890:ABCdefGHIjklMNOpqrsTUVwxyz choose.su
```

### 2. Обновление конфигурации

```bash
./quick-deploy.sh [DOMAIN] [BOT_TOKEN]
```

Пример:
```bash
./quick-deploy.sh choose.su 1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
```

## Структура URL

После развёртывания будут доступны:

- **Основной сайт**: `https://choose.su/` - Telegram WebApp
- **Админ панель**: `https://choose.su/admin` - Панель администратора
- **API**: `https://choose.su/api` - Backend API

## Требования

### DNS настройки

Для домена `choose.su` нужна только одна A-запись:
```
choose.su.    A    YOUR_SERVER_IP
```

### SSL сертификат

Let's Encrypt сертификат будет автоматически получен для основного домена.

## Управление

### Проверка статуса
```bash
docker-compose ps
```

### Просмотр логов
```bash
docker-compose logs -f
```

### Перезапуск сервисов
```bash
docker-compose restart
```

### Полное обновление
```bash
git pull origin main
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Конфигурация nginx

Nginx автоматически настраивается с проксированием:

```nginx
# HTTP redirect to HTTPS
server {
    listen 80;
    server_name choose.su;
    return 301 https://$host$request_uri;
}

# Main HTTPS server with path-based routing
server {
    listen 443 ssl;
    server_name choose.su;
    
    # Admin Panel - /admin
    location /admin {
        proxy_pass http://localhost:5173/;
        # ... proxy settings
    }
    
    # API - /api
    location /api {
        proxy_pass http://localhost:3000/api;
        # ... proxy settings
    }
    
    # Telegram WebApp - root path
    location / {
        proxy_pass http://localhost:5174/;
        # ... proxy settings
    }
}
```

## Переменные окружения

Файл `.env`:
```env
BOT_TOKEN=your_telegram_bot_token
DOMAIN=https://choose.su
```

## Troubleshooting

### Проблемы с SSL
```bash
sudo certbot --nginx --non-interactive --agree-tos --redirect -m admin@choose.su -d choose.su
```

### Проверка nginx конфигурации
```bash
sudo nginx -t
sudo systemctl restart nginx
```

### Очистка Docker
```bash
docker-compose down -v --remove-orphans
docker system prune -f
```

## Безопасность

- Все HTTP запросы автоматически перенаправляются на HTTPS
- Настроены безопасные SSL параметры
- Включены security headers
- Настроен firewall (UFW)

## Мониторинг

### Проверка доступности сервисов
```bash
curl -f https://choose.su/          # Telegram WebApp
curl -f https://choose.su/admin     # Admin Panel
curl -f https://choose.su/api       # API
```

### Логи сервисов
```bash
docker-compose logs backend-api     # API логи
docker-compose logs admin-app       # Admin логи
docker-compose logs telegram-app    # Telegram WebApp логи
docker-compose logs telegram-bot    # Bot логи
``` 