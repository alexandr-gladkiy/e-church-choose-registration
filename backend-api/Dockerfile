# Используем официальный Node.js образ
FROM node:18-alpine

# Рабочая директория
WORKDIR /app

# Копируем package.json и package-lock.json
COPY package*.json ./

# Устанавливаем зависимости
RUN npm install

# Копируем исходный код
COPY . .

# Открываем порт
EXPOSE 4000

# Переменные окружения по умолчанию (можно переопределить через docker-compose)
ENV PORT=4000

# Запуск приложения
CMD ["node", "index.js"] 