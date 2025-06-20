# Используем официальный Node.js образ
FROM node:18-alpine

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем package.json
COPY package.json ./

# Копируем package-lock.json если он существует
COPY package-lock.json* ./

# Устанавливаем зависимости (включая devDependencies для сборки)
RUN npm ci || npm install

# Копируем исходный код
COPY . .

# Создаем папку для данных
RUN mkdir -p /app/data

# Открываем порт
EXPOSE 5173

# Устанавливаем curl для отладки сетевого взаимодействия между контейнерами
RUN apk add --no-cache curl

# Создаем скрипт запуска
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo 'VITE_API_URL=http://localhost:3000/api npm run build' >> /app/start.sh && \
    echo 'npm run preview -- --host 0.0.0.0 --port 5173' >> /app/start.sh && \
    chmod +x /app/start.sh

# Запускаем приложение
CMD ["/app/start.sh"] 