const { Telegraf } = require('telegraf');

// Замените на ваш токен бота
const BOT_TOKEN = 'YOUR_BOT_TOKEN_HERE';

// URL вашего Web App (замените на реальный URL после деплоя)
const WEB_APP_URL = 'http://localhost:3003';

const bot = new Telegraf(BOT_TOKEN);

// Команда /start
bot.command('start', (ctx) => {
  const welcomeMessage = `
🎉 Добро пожаловать в систему регистрации на мероприятие!

Нажмите кнопку ниже, чтобы зарегистрироваться:
  `;

  ctx.reply(welcomeMessage, {
    reply_markup: {
      inline_keyboard: [[
        {
          text: '📝 Зарегистрироваться',
          web_app: { url: WEB_APP_URL }
        }
      ]]
    }
  });
});

// Команда /help
bot.command('help', (ctx) => {
  const helpMessage = `
🤖 Доступные команды:

/start - Начать регистрацию
/help - Показать эту справку
/status - Проверить статус регистрации

📱 Для регистрации используйте кнопку "Зарегистрироваться"
  `;

  ctx.reply(helpMessage);
});

// Команда /status (пример проверки статуса)
bot.command('status', async (ctx) => {
  try {
    // Здесь можно добавить проверку статуса регистрации
    // через API вашего приложения
    const response = await fetch(`${WEB_APP_URL}/api/registrations`);
    const registrations = await response.json();
    
    const userRegistration = registrations.find(
      reg => reg.telegramUserId === ctx.from.id
    );

    if (userRegistration) {
      ctx.reply(`
✅ Вы уже зарегистрированы!

📋 Ваши данные:
👤 Имя: ${userRegistration.fullName}
🏙 Город: ${userRegistration.city}
⛪ Церковь: ${userRegistration.church}
🏠 Расселение: ${userRegistration.needsAccommodation ? 'Нужно' : 'Не нужно'}
📧 Новости: ${userRegistration.newsletter ? 'Подписан' : 'Не подписан'}

🕐 Дата регистрации: ${new Date(userRegistration.timestamp).toLocaleString('ru-RU')}
      `);
    } else {
      ctx.reply(`
❌ Вы еще не зарегистрированы.

Нажмите кнопку "Зарегистрироваться" для участия в мероприятии.
      `, {
        reply_markup: {
          inline_keyboard: [[
            {
              text: '📝 Зарегистрироваться',
              web_app: { url: WEB_APP_URL }
            }
          ]]
        }
      });
    }
  } catch (error) {
    console.error('Ошибка при проверке статуса:', error);
    ctx.reply('❌ Ошибка при проверке статуса регистрации. Попробуйте позже.');
  }
});

// Обработка данных из Web App
bot.on('web_app_data', (ctx) => {
  const data = ctx.message.web_app_data.data;
  console.log('Получены данные из Web App:', data);
  
  // Здесь можно обработать данные, если они отправляются обратно в бота
  ctx.reply('✅ Данные получены! Спасибо за регистрацию.');
});

// Обработка ошибок
bot.catch((err, ctx) => {
  console.error(`Ошибка для ${ctx.updateType}:`, err);
  ctx.reply('❌ Произошла ошибка. Попробуйте позже.');
});

// Запуск бота
bot.launch()
  .then(() => {
    console.log('🤖 Бот запущен!');
    console.log(`📱 Web App URL: ${WEB_APP_URL}`);
  })
  .catch((error) => {
    console.error('❌ Ошибка запуска бота:', error);
  });

// Graceful stop
process.once('SIGINT', () => bot.stop('SIGINT'));
process.once('SIGTERM', () => bot.stop('SIGTERM')); 