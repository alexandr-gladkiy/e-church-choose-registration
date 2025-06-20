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

# Собираем приложение
RUN npm run build

# Открываем порт
EXPOSE 5174

# Запускаем приложение
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "5174"] 