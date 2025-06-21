# Руководство по миграции на новую конфигурацию

## Что изменилось

### Старая конфигурация (поддомены)
- **Telegram WebApp**: `https://choose.su`
- **Admin Panel**: `https://admin.choose.su`
- **API**: `https://api.choose.su`

### Новая конфигурация (один домен с путями)
- **Telegram WebApp**: `https://choose.su/`
- **Admin Panel**: `https://choose.su/admin`
- **API**: `https://choose.su/api`

## Преимущества новой конфигурации

1. **Простота DNS**: Нужна только одна A-запись
2. **Один SSL сертификат**: Только для основного домена
3. **Упрощённая настройка**: Меньше конфигурационных файлов
4. **Лучшая совместимость**: Меньше проблем с CORS и прокси

## Шаги миграции

### 1. Обновление кода

```bash
# Получите последние изменения
git pull origin main
```

### 2. Обновление .env файла

```bash
# Удалите старые переменные
# ADMIN_DOMAIN=https://admin.choose.su
# API_DOMAIN=https://api.choose.su

# Оставьте только
BOT_TOKEN=your_bot_token
DOMAIN=https://choose.su
```

### 3. Обновление DNS

Удалите A-записи для поддоменов:
```
admin.choose.su.    A    YOUR_SERVER_IP    # УДАЛИТЬ
api.choose.su.      A    YOUR_SERVER_IP    # УДАЛИТЬ
```

Оставьте только:
```
choose.su.          A    YOUR_SERVER_IP    # ОСТАВИТЬ
```

### 4. Пересборка и запуск

```bash
# Остановите старые контейнеры
docker-compose down

# Пересоберите с новой конфигурацией
docker-compose build --no-cache
docker-compose up -d
```

### 5. Обновление nginx

```bash
# Обновите nginx конфигурацию
sudo cp nginx.conf /etc/nginx/sites-available/event-registration
sudo nginx -t
sudo systemctl restart nginx
```

### 6. Обновление SSL сертификата

```bash
# Получите новый сертификат только для основного домена
sudo certbot --nginx --non-interactive --agree-tos --redirect -m admin@choose.su -d choose.su
```

## Проверка после миграции

### 1. Проверка доступности

```bash
# Telegram WebApp
curl -f https://choose.su/

# Admin Panel
curl -f https://choose.su/admin

# API
curl -f https://choose.su/api/registration-settings
```

### 2. Проверка функциональности

1. **Telegram Bot**: Отправьте `/start` боту и проверьте кнопку регистрации
2. **Admin Panel**: Войдите в админ панель и проверьте все функции
3. **API**: Проверьте все API endpoints

### 3. Проверка логов

```bash
# Проверьте логи всех сервисов
docker-compose logs backend-api
docker-compose logs admin-app
docker-compose logs telegram-app
docker-compose logs telegram-bot
```

## Откат (если что-то пошло не так)

### 1. Восстановление DNS

Добавьте обратно A-записи для поддоменов:
```
admin.choose.su.    A    YOUR_SERVER_IP
api.choose.su.      A    YOUR_SERVER_IP
```

### 2. Восстановление .env

```bash
# Восстановите старые переменные
BOT_TOKEN=your_bot_token
DOMAIN=https://choose.su
ADMIN_DOMAIN=https://admin.choose.su
API_DOMAIN=https://api.choose.su
```

### 3. Восстановление nginx

```bash
# Восстановите старую nginx конфигурацию
sudo cp nginx.conf.backup /etc/nginx/sites-available/event-registration
sudo nginx -t
sudo systemctl restart nginx
```

### 4. Перезапуск сервисов

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Автоматическая миграция

Для автоматической миграции используйте:

```bash
./quick-deploy.sh choose.su YOUR_BOT_TOKEN
```

Этот скрипт автоматически:
- Обновит .env файл
- Пересоберёт контейнеры
- Применит новую конфигурацию

## Часто задаваемые вопросы

### Q: Нужно ли обновлять ссылки в Telegram боте?
A: Нет, бот автоматически использует переменную `WEBAPP_URL`, которая теперь указывает на основной домен.

### Q: Что делать с существующими пользователями?
A: Все данные пользователей сохраняются в базе данных, никаких изменений не требуется.

### Q: Нужно ли обновлять SSL сертификат?
A: Да, нужно получить новый сертификат только для основного домена.

### Q: Работает ли старая конфигурация параллельно?
A: Нет, рекомендуется полностью переключиться на новую конфигурацию.

## Поддержка

Если возникли проблемы при миграции:

1. Проверьте логи: `docker-compose logs -f`
2. Проверьте nginx: `sudo nginx -t`
3. Проверьте SSL: `sudo certbot certificates`
4. Создайте issue в репозитории с подробным описанием проблемы 