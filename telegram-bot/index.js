import { Telegraf, Markup } from 'telegraf';

const bot = new Telegraf(process.env.BOT_TOKEN);
const webAppUrl = process.env.WEBAPP_URL || 'http://localhost:5174';

bot.start((ctx) => {
  return ctx.reply(
    'Добро пожаловать! Для регистрации нажмите кнопку ниже:',
    Markup.keyboard([
      [Markup.button.webApp('Открыть регистрацию', webAppUrl)]
    ]).resize()
  );
});

bot.launch();

// Enable graceful stop
process.once('SIGINT', () => bot.stop('SIGINT'));
process.once('SIGTERM', () => bot.stop('SIGTERM')); 