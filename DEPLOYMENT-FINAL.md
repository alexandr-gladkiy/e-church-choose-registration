# 🚀 Инструкция по развёртыванию event-registration

## Подготовка к деплою

### 1. Требования к серверу
- Ubuntu 20.04+ или Debian 11+
- Минимум 2GB RAM
- 20GB свободного места
- Открытые порты: 22 (SSH), 80 (HTTP), 443 (HTTPS)

### 2. Подготовка доменов
Убедитесь, что у вас есть:
- Основной домен (например: `choose.su`)
- Поддомен для админки (например: `admin.choose.su`)
- Поддомен для API (например: `api.choose.su`)

DNS записи должны указывать на IP вашего сервера.

### 3. Telegram Bot Token
Получите токен бота у @BotFather в Telegram.

## Развёртывание

### Автоматическое развёртывание

1. **Подключитесь к серверу:**
   ```bash
   ssh user@your-server-ip
   ```

2. **Скачайте скрипт деплоя:**
   ```bash
   wget https://raw.githubusercontent.com/your-username/event-registration/main/deploy.sh
   chmod +x deploy.sh
   ```

3. **Запустите деплой:**
   ```bash
   ./deploy.sh
   ```

4. **Следуйте инструкциям:**
   - Введите ссылку на git-репозиторий
   - Введите токен Telegram-бота
   - Введите основной домен
   - Введите поддомен для админки
   - Введите поддомен для API

### Ручное развёртывание

Если нужно передать параметры напрямую:
```bash
./deploy.sh "https://github.com/your-username/event-registration.git" "YOUR_BOT_TOKEN" "choose.su" "admin.choose.su" "api.choose.su"
```

## Что делает скрипт

1. **Обновляет систему** и устанавливает необходимые пакеты
2. **Устанавливает Docker** и Docker Compose
3. **Клонирует проект** из git-репозитория
4. **Настраивает nginx** с поддоменами и HTTPS
5. **Устанавливает SSL сертификаты** через Let's Encrypt
6. **Настраивает firewall** (UFW)
7. **Собирает и запускает** Docker контейнеры
8. **Создаёт systemd сервис** для автозапуска
9. **Создаёт скрипт управления** проектом

## Управление проектом

После деплоя используйте команды:

```bash
# Статус сервисов
event-registration-manage status

# Просмотр логов
event-registration-manage logs

# Перезапуск
event-registration-manage restart

# Обновление (git pull + rebuild)
event-registration-manage update

# Остановка
event-registration-manage stop

# Запуск
event-registration-manage start
```

## Доступ к сервисам

После успешного деплоя:

- **Telegram WebApp:** https://choose.su
- **Admin Panel:** https://admin.choose.su
- **API:** https://api.choose.su

## Первоначальная настройка

1. **Войдите в админ-панель:**
   - URL: https://admin.choose.su
   - Логин: `admin`
   - Пароль: `admin`

2. **Настройте параметры регистрации:**
   - Максимальное количество участников
   - Разрешить/запретить доступ через браузер
   - Другие настройки

3. **Протестируйте бота:**
   - Найдите вашего бота в Telegram
   - Отправьте `/start`
   - Проверьте регистрацию

## Устранение неполадок

### Проверка статуса
```bash
docker-compose ps
docker-compose logs [service-name]
```

### Пересборка
```bash
cd /opt/event-registration
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Проверка SSL
```bash
sudo certbot certificates
sudo certbot renew --dry-run
```

### Проверка nginx
```bash
sudo nginx -t
sudo systemctl status nginx
```

## Безопасность

- Все сервисы работают через HTTPS
- Настроен firewall (UFW)
- SSL сертификаты автоматически обновляются
- Пароли хранятся в захешированном виде

## Резервное копирование

База данных автоматически сохраняется в Docker volume:
```bash
# Создание бэкапа
docker exec event-registration-postgres-1 pg_dump -U postgres event_registration > backup.sql

# Восстановление
docker exec -i event-registration-postgres-1 psql -U postgres event_registration < backup.sql
```

---

**Готово!** Ваше приложение развёрнуто и готово к использованию. 🎉 