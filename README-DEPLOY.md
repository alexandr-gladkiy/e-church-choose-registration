# 🚀 Быстрое развёртывание Event Registration

## Варианты развёртывания

### 1. Быстрое развёртывание (рекомендуется для тестирования)

```bash
# Скачайте скрипт
wget https://raw.githubusercontent.com/your-username/event-registration/main/quick-deploy.sh
chmod +x quick-deploy.sh

# Запустите развёртывание
./quick-deploy.sh https://github.com/your-username/event-registration.git YOUR_BOT_TOKEN
```

**Результат:**
- Telegram WebApp: `http://YOUR_SERVER_IP:5174`
- Admin Panel: `http://YOUR_SERVER_IP:5173`
- API: `http://YOUR_SERVER_IP:3000`

### 2. Полное развёртывание (с nginx и доменом)

```bash
# Скачайте скрипт
wget https://raw.githubusercontent.com/your-username/event-registration/main/deploy.sh
chmod +x deploy.sh

# Запустите развёртывание
./deploy.sh https://github.com/your-username/event-registration.git YOUR_BOT_TOKEN yourdomain.com
```

**Результат:**
- Telegram WebApp: `https://yourdomain.com`
- Admin Panel: `https://yourdomain.com/admin`
- API: `https://yourdomain.com/api`

## Предварительные требования

1. **Сервер:** Ubuntu 20.04+ или Debian 11+
2. **Домен:** (опционально для быстрого развёртывания)
3. **Bot Token:** Получите у [@BotFather](https://t.me/BotFather)

## Управление после развёртывания

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

## Тестирование

1. Откройте Telegram
2. Найдите вашего бота
3. Отправьте `/start`
4. Нажмите кнопку "Открыть регистрацию"

## Подробная инструкция

См. файл [DEPLOYMENT.md](DEPLOYMENT.md) для полной инструкции с настройкой SSL, мониторингом и устранением неполадок.

---

**Время развёртывания:** 5-10 минут (быстрое) / 15-20 минут (полное) 