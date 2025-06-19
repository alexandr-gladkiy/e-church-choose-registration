# Используем официальный Node.js образ
FROM node:18-alpine

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем package.json
COPY admin-service/package.json ./

# Устанавливаем зависимости
RUN npm install

# Копируем исходный код
COPY admin-service/. ./

# Копируем общий модуль работы с БД
COPY db-management ./db-management

# Создаем папку для данных
RUN mkdir -p /app/data

# Открываем порт
EXPOSE 3005

# Устанавливаем curl для отладки сетевого взаимодействия между контейнерами
RUN apk add --no-cache curl

# Запускаем приложение
CMD ["npm", "start"] 