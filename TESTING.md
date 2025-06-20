# 🧪 Тестирование Event Registration

## Текущее состояние

✅ **Все сервисы запущены:**
- **PostgreSQL** (база данных) - порт 5432
- **Backend API** - http://localhost:3000
- **Admin Panel** - http://localhost:5173
- **Telegram WebApp** - http://localhost:5174
- **Telegram Bot** - запущен с токеном

## Тестирование Telegram Bot

### 1. Найдите вашего бота в Telegram
- Имя бота: (узнайте у @BotFather)
- Или используйте прямую ссылку: `https://t.me/your_bot_username`

### 2. Отправьте команду `/start`
Бот должен ответить сообщением с кнопкой "Открыть регистрацию"

### 3. Нажмите кнопку "Открыть регистрацию"
Должен открыться WebApp с формой регистрации

## Тестирование WebApp

### 1. Откройте в браузере
```
http://localhost:5174
```

### 2. Проверьте функциональность
- ✅ Загрузка страницы
- ✅ Отображение формы регистрации
- ✅ Работа слайдера (если есть)
- ✅ Отправка формы

## Тестирование Admin Panel

### 1. Откройте в браузере
```
http://localhost:5173
```

### 2. Войдите в систему
- **Логин:** `admin`
- **Пароль:** `admin123`

### 3. Проверьте функциональность
- ✅ Просмотр зарегистрированных пользователей
- ✅ Статистика
- ✅ Настройки

## Тестирование API

### 1. Проверьте доступность
```bash
curl http://localhost:3000/api/health
```

### 2. Проверьте регистрацию пользователя
```bash
curl -X POST http://localhost:3000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Тест",
    "email": "test@example.com",
    "phone": "+1234567890",
    "city": "Москва",
    "telegramId": "123456789"
  }'
```

## Устранение проблем

### Бот не отвечает
```bash
# Проверьте логи бота
docker-compose logs telegram-bot

# Перезапустите бота
docker-compose restart telegram-bot
```

### WebApp не открывается
```bash
# Проверьте логи WebApp
docker-compose logs telegram-app

# Перезапустите WebApp
docker-compose restart telegram-app
```

### Проблемы с API
```bash
# Проверьте логи API
docker-compose logs backend-api

# Проверьте базу данных
docker-compose logs postgres
```

## Готово к развёртыванию на сервер

Если всё работает локально, можно развернуть на сервер:

1. **Загрузите проект в GitHub**
2. **Используйте скрипт развёртывания:**
   ```bash
   ./quick-deploy.sh https://github.com/your-username/event-registration.git 7487987244:AAGFxvVCBMsndF3Zf3cSX3OKSdpKXbfGR_Y
   ```

## Контакты для поддержки

При возникновении проблем:
1. Проверьте логи: `docker-compose logs [service-name]`
2. Проверьте статус: `docker-compose ps`
3. Перезапустите сервис: `docker-compose restart [service-name]`

---

**Успешного тестирования! 🚀** 