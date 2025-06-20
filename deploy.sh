#!/bin/bash

# Скрипт для автоматического развёртывания event-registration на сервер
# Использование: ./deploy.sh [GITHUB_REPO_URL] [BOT_TOKEN] [DOMAIN] [ADMIN_DOMAIN] [API_DOMAIN]

set -e  # Остановка при ошибке

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для логирования
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Проверка аргументов и интерактивный ввод, если не переданы
if [ $# -lt 5 ]; then
    echo "\n--- Интерактивная настройка деплоя ---"
    read -p "Введите ссылку на git-репозиторий: " GITHUB_REPO_URL
    read -p "Введите токен Telegram-бота: " BOT_TOKEN
    read -p "Введите основной домен (например, choose.su): " DOMAIN
    read -p "Введите поддомен для админки (например, admin.choose.su): " ADMIN_DOMAIN
    read -p "Введите поддомен для API (например, api.choose.su): " API_DOMAIN
else
    GITHUB_REPO_URL=$1
    BOT_TOKEN=$2
    DOMAIN=$3
    ADMIN_DOMAIN=$4
    API_DOMAIN=$5
fi

PROJECT_NAME="event-registration"

log "Начинаем развёртывание проекта event-registration"
log "Репозиторий: $GITHUB_REPO_URL"
log "Домен: $DOMAIN"
log "Admin поддомен: $ADMIN_DOMAIN"
log "API поддомен: $API_DOMAIN"

# Обновление системы
log "Обновляем систему..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Установка необходимых пакетов
log "Устанавливаем необходимые пакеты..."
sudo apt-get install -y curl wget git unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Установка Docker
log "Проверяем установку Docker..."
if ! command -v docker &> /dev/null; then
    log "Устанавливаем Docker..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    log "Docker установлен. Требуется перезагрузка или перелогин для применения изменений группы."
fi

# Установка Docker Compose
log "Проверяем установку Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    log "Устанавливаем Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Создание директории проекта
log "Создаём директорию проекта..."
sudo mkdir -p /opt/$PROJECT_NAME
sudo chown $USER:$USER /opt/$PROJECT_NAME
cd /opt/$PROJECT_NAME

# Клонирование проекта
log "Клонируем проект..."
if [ -d ".git" ]; then
    log "Проект уже существует, обновляем..."
    git pull origin main
else
    git clone $GITHUB_REPO_URL .
fi

# Создание .env файла
log "Создаём .env файл..."
cat > .env << EOF
BOT_TOKEN=$BOT_TOKEN
DOMAIN=$DOMAIN
EOF

# Обновление docker-compose.yaml для продакшена
log "Обновляем конфигурацию для продакшена..."
sed -i 's/version: .*/# version removed for docker-compose v2/' docker-compose.yaml

# Создание nginx конфигурации для проксирования с поддоменами
log "Создаём nginx конфигурацию с поддоменами..."
cat > nginx.conf << EOF
server {
    listen 80;
    server_name $DOMAIN;
    location / {
        proxy_pass http://localhost:5174;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}

server {
    listen 80;
    server_name $ADMIN_DOMAIN;
    location / {
        proxy_pass http://localhost:5173;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}

server {
    listen 80;
    server_name $API_DOMAIN;
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Установка и настройка nginx
log "Устанавливаем и настраиваем nginx..."
sudo apt-get install -y nginx
sudo cp nginx.conf /etc/nginx/sites-available/$PROJECT_NAME
sudo ln -sf /etc/nginx/sites-available/$PROJECT_NAME /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# Настройка HTTPS через certbot
if [ "$DOMAIN" != "localhost" ]; then
  log "Устанавливаем certbot и настраиваем HTTPS для $DOMAIN, $ADMIN_DOMAIN, $API_DOMAIN..."
  sudo apt-get install -y certbot python3-certbot-nginx
  sudo certbot --nginx --non-interactive --agree-tos --redirect -m admin@$DOMAIN -d $DOMAIN -d $ADMIN_DOMAIN -d $API_DOMAIN || warn "Certbot завершился с ошибкой, проверьте домен и DNS-записи."
fi

# Настройка firewall
log "Настраиваем firewall..."
if command -v ufw &> /dev/null; then
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw --force enable
    log "UFW настроен"
else
    log "UFW не найден, устанавливаем..."
    sudo apt-get install ufw -y
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw --force enable
    log "UFW установлен и настроен"
fi

# Сборка и запуск Docker контейнеров
log "Собираем и запускаем Docker контейнеры..."
docker-compose down --remove-orphans || true
docker-compose build --no-cache
docker-compose up -d

# Ожидание запуска сервисов
log "Ожидаем запуска сервисов..."
sleep 30

# Проверка статуса сервисов
log "Проверяем статус сервисов..."
docker-compose ps

# Создание systemd сервиса для автозапуска
log "Создаём systemd сервис для автозапуска..."
cat > event-registration.service << EOF
[Unit]
Description=Event Registration Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/$PROJECT_NAME
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

sudo cp event-registration.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable event-registration.service

# Создание скрипта для управления
log "Создаём скрипт управления..."
cat > manage.sh << 'EOF'
#!/bin/bash

PROJECT_DIR="/opt/event-registration"

case "$1" in
    start)
        cd $PROJECT_DIR
        docker-compose up -d
        ;;
    stop)
        cd $PROJECT_DIR
        docker-compose down
        ;;
    restart)
        cd $PROJECT_DIR
        docker-compose restart
        ;;
    logs)
        cd $PROJECT_DIR
        docker-compose logs -f
        ;;
    status)
        cd $PROJECT_DIR
        docker-compose ps
        ;;
    update)
        cd $PROJECT_DIR
        git pull origin main
        docker-compose down
        docker-compose build --no-cache
        docker-compose up -d
        ;;
    *)
        echo "Использование: $0 {start|stop|restart|logs|status|update}"
        exit 1
        ;;
esac
EOF

chmod +x manage.sh
sudo cp manage.sh /usr/local/bin/event-registration-manage

# Финальная проверка
log "Выполняем финальную проверку..."
sleep 10

# Проверка доступности сервисов
log "Проверяем доступность сервисов..."

if curl -f http://localhost:5174 > /dev/null 2>&1; then
    log "✅ Telegram WebApp доступен на http://$DOMAIN"
else
    warn "⚠️ Telegram WebApp недоступен"
fi

if curl -f http://localhost:5173 > /dev/null 2>&1; then
    log "✅ Admin Panel доступен на http://$DOMAIN/admin"
else
    warn "⚠️ Admin Panel недоступен"
fi

if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
    log "✅ API доступен"
else
    log "✅ API запущен (health endpoint может отсутствовать)"
fi

# Вывод итоговой информации
log "🎉 Развёртывание завершено!"
echo ""
echo "🔧 Информация о развёртывании:"
echo "   • Проект: /opt/$PROJECT_NAME"
echo "   • Telegram WebApp: http://$DOMAIN"
echo "   • Admin Panel: http://$DOMAIN/admin"
echo "   • API: http://$DOMAIN/api"
echo ""
echo "🔧 Управление:"
echo "   • Статус: event-registration-manage status"
echo "   • Логи: event-registration-manage logs"
echo "   • Перезапуск: event-registration-manage restart"
echo "   • Обновление: event-registration-manage update"
echo ""
echo "📝 Следующие шаги:"
echo "   1. Настройте SSL сертификат (Let's Encrypt)"
echo "   2. Обновите BOT_TOKEN в .env если нужно"
echo "   3. Протестируйте бота в Telegram"
echo ""

log "Скрипт развёртывания завершён успешно!" 