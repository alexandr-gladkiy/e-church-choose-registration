# Используем официальный Node.js образ
FROM node:18-alpine

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем package.json
COPY telegram-app/package.json ./

# Устанавливаем зависимости
RUN npm install

# Копируем исходный код
COPY telegram-app/. ./

# Копируем общий модуль работы с БД
COPY db-management ./db-management

# Собираем приложение
RUN npm run build

# Создаем папку для данных
RUN mkdir -p /app/data

# Открываем порт
EXPOSE 3002

# Запускаем приложение
CMD ["npm", "start"] 