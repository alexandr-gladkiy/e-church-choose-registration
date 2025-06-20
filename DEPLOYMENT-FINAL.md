# 🚀 Финальная инструкция по развёртыванию Event Registration

## ✅ Исправленные проблемы

- **package-lock.json not found** - исправлено в Dockerfile
- **UFW command not found** - добавлена автоматическая установка
- **Vite not found** - исправлено в Dockerfile
- **Docker cache issues** - добавлена очистка кэша

---

## Быстрое развёртывание (рекомендуется)

### 1. Подключение к серверу
```bash
ssh username@your-server-ip
```

### 2. Скачивание скрипта
```bash
wget https://raw.githubusercontent.com/your-username/event-registration/main/quick-deploy.sh
chmod +x quick-deploy.sh
```

### 3. Запуск развёртывания
```bash
./quick-deploy.sh https://github.com/your-username/event-registration.git 7487987244:AAGFxvVCBMsndF3Zf3cSX3OKSdpKXbfGR_Y
```

**Результат:**
- Telegram WebApp: `http://YOUR_SERVER_IP:5174`
- Admin Panel: `http://YOUR_SERVER_IP:5173`
- API: `http://YOUR_SERVER_IP:3000`

---

## Полное развёртывание (с доменом)

### 1. Подключение к серверу
```bash
ssh username@your-server-ip
```

### 2. Скачивание скрипта
```bash
wget https://raw.githubusercontent.com/your-username/event-registration/main/deploy.sh
chmod +x deploy.sh
```

### 3. Запуск развёртывания
```bash
./deploy.sh https://github.com/your-username/event-registration.git 7487987244:AAGFxvVCBMsndF3Zf3cSX3OKSdpKXbfGR_Y yourdomain.com
```

**Результат:**
- Telegram WebApp: `https://yourdomain.com`
- Admin Panel: `https://yourdomain.com/admin`
- API: `https://yourdomain.com/api`

---

## Развёртывание на домен choose.su с HTTPS

### 1. Подключение к серверу
```bash
ssh username@choose.su
```

### 2. Убедитесь, что DNS-запись A домена choose.su указывает на ваш сервер
- Проверьте через https://whois.domaintools.com/choose.su или аналогичный сервис
- Откройте порты 80 и 443 в firewall (см. раздел ниже)

### 3. Скачайте и запустите скрипт деплоя
```bash
wget https://raw.githubusercontent.com/your-username/event-registration/main/deploy.sh
chmod +x deploy.sh
./deploy.sh https://github.com/your-username/event-registration.git <BOT_TOKEN> choose.su
```

### 4. Сертификат и HTTPS
- Скрипт автоматически установит nginx и certbot, получит и настроит SSL-сертификат для choose.su
- Все сервисы будут доступны по HTTPS:
  - Telegram WebApp: https://choose.su
  - Admin Panel: https://choose.su/admin
  - API: https://choose.su/api

---

## Развёртывание с поддоменами для admin и api

### 1. Пропишите в DNS:
- choose.su — основной домен (Telegram WebApp)
- admin.choose.su — поддомен для админки
- api.choose.su — поддомен для API

Все поддомены должны указывать на IP вашего сервера (A-запись).

### 2. Запустите скрипт деплоя с параметрами:
```bash
./deploy.sh https://github.com/your-username/event-registration.git <BOT_TOKEN> choose.su admin.choose.su api.choose.su
```

### 3. После деплоя:
- Telegram WebApp: https://choose.su
- Admin Panel: https://admin.choose.su
- API: https://api.choose.su

---

## Что делают скрипты

### Автоматически устанавливают:
- ✅ Docker и Docker Compose
- ✅ UFW (firewall)
- ✅ nginx (для полного развёртывания)
- ✅ Все зависимости

### Автоматически настраивают:
- ✅ Переменные окружения (.env)
- ✅ Firewall правила
- ✅ Автозапуск сервисов
- ✅ Скрипты управления

### Автоматически запускают:
- ✅ PostgreSQL (база данных)
- ✅ Backend API
- ✅ Admin Panel
- ✅ Telegram WebApp
- ✅ Telegram Bot

---

## Управление после развёртывания

### Команды управления
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

### Ручное управление
```bash
cd /opt/event-registration
docker-compose ps
docker-compose logs -f
docker-compose restart
```

---

## Тестирование

### 1. Telegram Bot
1. Найдите вашего бота в Telegram
2. Отправьте `/start`
3. Нажмите кнопку "Открыть регистрацию"

### 2. WebApp
```bash
# Откройте в браузере
http://YOUR_SERVER_IP:5174
```

### 3. Admin Panel
```bash
# Откройте в браузере
http://YOUR_SERVER_IP:5173

# Логин: admin
# Пароль: admin123
```

---

## Устранение проблем

### Проблемы с UFW
```bash
# Установка UFW
sudo apt-get install ufw -y

# Настройка правил
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 5173/tcp
sudo ufw allow 5174/tcp
sudo ufw allow 3000/tcp
sudo ufw --force enable
```

### Проблемы с Docker
```bash
# Очистка кэша
docker system prune -f

# Пересборка
docker-compose build --no-cache
```

### Проблемы с package-lock.json
```bash
# Пересоздание package-lock.json
cd /opt/event-registration/admin-app
rm package-lock.json
npm install

cd /opt/event-registration/telegram-app
rm package-lock.json
npm install
```

---

## Мониторинг

### Проверка ресурсов
```bash
# Использование диска
df -h

# Использование памяти
free -h

# Использование CPU
htop

# Логи системы
sudo journalctl -f
```

### Проверка сервисов
```bash
# Статус всех контейнеров
docker-compose ps

# Логи всех сервисов
docker-compose logs

# Логи конкретного сервиса
docker-compose logs telegram-bot
docker-compose logs telegram-app
docker-compose logs backend-api
```

---

## Резервное копирование

### Создание бэкапа
```bash
# Бэкап базы данных
docker-compose exec postgres pg_dump -U postgres event_registration > backup_$(date +%Y%m%d_%H%M%S).sql

# Бэкап всего проекта
tar -czf event-registration-backup-$(date +%Y%m%d_%H%M%S).tar.gz /opt/event-registration
```

### Восстановление
```bash
# Восстановление базы данных
docker-compose exec -T postgres psql -U postgres event_registration < backup.sql
```

---

## Обновление

### Автоматическое обновление
```bash
# Быстрое развёртывание
event-manage update

# Полное развёртывание
event-registration-manage update
```

### Ручное обновление
```bash
cd /opt/event-registration
git pull origin main
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## Безопасность

### Firewall
```bash
# Проверка статуса UFW
sudo ufw status

# Открытие дополнительных портов
sudo ufw allow 8080/tcp
```

### SSL сертификат
```bash
# Установка Certbot
sudo apt-get install certbot python3-certbot-nginx

# Получение SSL сертификата
sudo certbot --nginx -d yourdomain.com

# Автообновление
sudo crontab -e
# Добавьте строку:
0 12 * * * /usr/bin/certbot renew --quiet
```

---

## CI/CD: Автоматизация деплоя через GitHub Actions

### 1. Создайте SSH-ключ для GitHub Actions
На сервере выполните:
```bash
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github-actions -N ""
cat ~/.ssh/github-actions.pub
```
Добавьте публичный ключ в authorized_keys на сервере:
```bash
echo "<содержимое .pub>" >> ~/.ssh/authorized_keys
```

### 2. Добавьте приватный ключ в Secrets репозитория
- Откройте GitHub → Settings → Secrets and variables → Actions
- Добавьте секрет с именем `SSH_KEY` и содержимым приватного ключа (`github-actions`)
- Добавьте секрет `SERVER_HOST` (например, choose.su)
- Добавьте секрет `SERVER_USER` (например, root или deploy)

### 3. Создайте workflow .github/workflows/deploy.yml
```yaml
name: Deploy to Server
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Copy files via SSH and run deploy.sh
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /opt/event-registration || git clone https://github.com/your-username/event-registration.git /opt/event-registration
            cd /opt/event-registration
            git pull origin main
            chmod +x deploy.sh
            ./deploy.sh
```

### 4. Как это работает
- При каждом пуше в main GitHub Actions подключается по SSH к серверу и запускает deploy.sh
- Все параметры будут запрошены интерактивно, либо можно доработать скрипт для передачи переменных через ENV

---

## Готово! 🎉

После выполнения всех шагов у вас будет полностью работающая система:

- ✅ **Telegram Bot** с вашим токеном
- ✅ **WebApp** для регистрации пользователей
- ✅ **Admin Panel** для управления
- ✅ **API** для обработки данных
- ✅ **База данных** PostgreSQL
- ✅ **Автоматическое управление** сервисами

**Время развёртывания:** 10-15 минут

**Готово к использованию! 🚀** 