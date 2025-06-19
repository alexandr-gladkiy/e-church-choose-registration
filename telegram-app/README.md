# Telegram Web App - Регистрация на мероприятие

Telegram Web App для регистрации участников на мероприятие с автоматическим получением данных пользователя из Telegram.

## 🚀 Особенности

- **Интеграция с Telegram Web App API** - автоматическое получение данных пользователя
- **Автозаполнение имени** из профиля Telegram
- **Сохранение Telegram данных** (ID, username, имя, фамилия, язык)
- **Адаптивный дизайн** для мобильных устройств
- **Валидация формы** с красивыми уведомлениями
- **Автодополнение городов** России
- **REST API** для сохранения данных

## 📱 Telegram Web App

Приложение автоматически:
- Получает данные пользователя из Telegram
- Автозаполняет имя пользователя
- Сохраняет Telegram ID и username
- Показывает уведомления через Telegram API
- Адаптируется под тему Telegram

## 🛠 Установка и запуск

### 1. Установка зависимостей
```bash
cd telegram-app
npm install
```

### 2. Запуск в режиме разработки
```bash
# Запуск фронтенда и бэкенда одновременно
npm run dev:full
```

Или по отдельности:
```bash
# Только фронтенд (порт 3002)
npm run dev

# Только бэкенд (порт 3003)
npm run server
```

### 3. Сборка для продакшена
```bash
npm run build
npm start
```

## 🌐 Доступные URL

- **Фронтенд**: http://localhost:3002
- **API**: http://localhost:3003/api
- **Telegram Web App**: http://localhost:3003

## 📊 API Endpoints

### POST /api/register
Регистрация нового участника

**Тело запроса:**
```json
{
  "fullName": "Иван Иванов",
  "city": "Москва",
  "church": "Церковь Святого Духа",
  "comments": "Дополнительная информация",
  "needsAccommodation": true,
  "newsletter": false,
  "telegramUserId": 123456789,
  "telegramUsername": "ivan_ivanov",
  "telegramFirstName": "Иван",
  "telegramLastName": "Иванов",
  "telegramLanguageCode": "ru"
}
```

### GET /api/registrations
Получение всех регистраций

### GET /api/stats
Получение статистики регистраций

## 📁 Структура проекта

```
telegram-app/
├── src/
│   ├── App.vue          # Главный компонент
│   ├── main.js          # Точка входа
│   └── style.css        # Стили
├── server.js            # Express сервер
├── package.json         # Зависимости
├── vite.config.js       # Конфигурация Vite
└── index.html           # HTML шаблон
```

## 🔧 Настройка для Telegram Bot

Для использования в Telegram Bot API:

1. Создайте бота через @BotFather
2. Получите токен бота
3. Настройте Web App URL в боте
4. Используйте команду `/setmenubutton` для установки кнопки меню

### Пример кода для бота:
```javascript
const { Telegraf } = require('telegraf');

const bot = new Telegraf('YOUR_BOT_TOKEN');

bot.command('start', (ctx) => {
  ctx.reply('Добро пожаловать!', {
    reply_markup: {
      inline_keyboard: [[
        {
          text: '📝 Зарегистрироваться',
          web_app: { url: 'https://your-domain.com' }
        }
      ]]
    }
  });
});

bot.launch();
```

## 📱 Поля формы

- **Полное имя** - автозаполняется из Telegram
- **Город** - автодополнение из списка городов России
- **Название Церкви** - обязательное поле
- **Комментарии** - дополнительная информация
- **Нуждаюсь в расселении** - чекбокс
- **Подписка на новости** - чекбокс
- **Согласие с условиями** - обязательное

## 🔒 Безопасность

- Валидация всех полей на клиенте и сервере
- Защита от XSS атак
- CORS настройки для безопасности
- Валидация данных Telegram

## 📈 Данные пользователя Telegram

Приложение автоматически сохраняет:
- `telegramUserId` - уникальный ID пользователя
- `telegramUsername` - username пользователя
- `telegramFirstName` - имя
- `telegramLastName` - фамилия
- `telegramLanguageCode` - код языка

## 🎨 Кастомизация

### Изменение темы
В файле `src/App.vue` найдите функцию `initTelegram()` и измените цвета:

```javascript
tg.setHeaderColor('#667eea')
tg.setBackgroundColor('#667eea')
```

### Добавление городов
В файле `src/App.vue` найдите массив `cities` и добавьте нужные города.

## 🚀 Деплой

### Heroku
```bash
heroku create your-app-name
git push heroku main
```

### Vercel
```bash
npm install -g vercel
vercel
```

### Netlify
```bash
npm run build
# Загрузите папку dist в Netlify
```

## 📞 Поддержка

При возникновении проблем:
1. Проверьте консоль браузера
2. Проверьте логи сервера
3. Убедитесь, что все порты свободны
4. Проверьте настройки CORS

## 📄 Лицензия

MIT License 