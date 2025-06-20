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

# Проверка наличия docker-compose.yaml
if [ ! -f "docker-compose.yaml" ]; then
    error "Файл docker-compose.yaml не найден в репозитории!"
fi

# Создание .env файла
log "Создаём .env файл..."
cat > .env << EOF
BOT_TOKEN=$BOT_TOKEN
DOMAIN=https://$DOMAIN
ADMIN_DOMAIN=https://$ADMIN_DOMAIN
API_DOMAIN=https://$API_DOMAIN
EOF

# Обновление docker-compose.yaml для продакшена
log "Обновляем конфигурацию для продакшена..."
sed -i 's/version: .*/# version removed for docker-compose v2/' docker-compose.yaml

# Создание nginx конфигурации для проксирования с поддоменами и HTTPS
log "Создаём nginx конфигурацию с поддоменами и HTTPS..."
cat > nginx.conf << "EOF"
# HTTP redirect to HTTPS
server {
    listen 80;
    server_name $DOMAIN $ADMIN_DOMAIN $API_DOMAIN;
    return 301 https://\$host\$request_uri;
}

# Telegram WebApp HTTPS
server {
    listen 443 ssl;
    server_name $DOMAIN;
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    include ssl-params.conf;
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

# Admin Panel HTTPS
server {
    listen 443 ssl;
    server_name $ADMIN_DOMAIN;
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    include ssl-params.conf;
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

# API HTTPS
server {
    listen 443 ssl;
    server_name $API_DOMAIN;
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    include ssl-params.conf;
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

# Создаём ssl-params.conf с безопасными настройками
cat > ssl-params.conf << EOF
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers on;
ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
ssl_ecdh_curve secp384r1;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header Referrer-Policy "no-referrer-when-downgrade";
add_header Content-Security-Policy "default-src 'self'";
EOF

# Установка и настройка nginx
log "Устанавливаем и настраиваем nginx..."
sudo apt-get install -y nginx
sudo cp nginx.conf /etc/nginx/sites-available/$PROJECT_NAME
sudo cp ssl-params.conf /etc/nginx/ssl-params.conf
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

# Остановка и удаление всех контейнеров и сетей Docker
log "Останавливаю и удаляю все контейнеры и сети Docker..."
docker-compose down -v --remove-orphans || true

docker container prune -f || true
docker network prune -f || true

# Сборка и запуск Docker контейнеров
log "Собираем и запускаем Docker контейнеры..."
# Данные Postgres сохраняются между пересборками благодаря volume pgdata
# (см. docker-compose.yaml: pgdata:/var/lib/postgresql/data)
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
    log "✅ Telegram WebApp доступен на https://$DOMAIN"
else
    warn "⚠️ Telegram WebApp недоступен"
fi

if curl -f http://localhost:5173 > /dev/null 2>&1; then
    log "✅ Admin Panel доступен на https://$ADMIN_DOMAIN"
else
    warn "⚠️ Admin Panel недоступен"
fi

if curl -f http://localhost:3000 > /dev/null 2>&1; then
    log "✅ API доступен на https://$API_DOMAIN"
else
    warn "⚠️ API недоступен"
fi

# Вывод итоговой информации
log "🎉 Развёртывание завершено!"
echo ""
echo "🔧 Информация о развёртывании:"
echo "   • Проект: /opt/$PROJECT_NAME"
echo "   • Telegram WebApp: https://$DOMAIN"
echo "   • Admin Panel: https://$ADMIN_DOMAIN"
echo "   • API: https://$API_DOMAIN"
echo ""
echo "🔧 Управление:"
echo "   • Статус: event-registration-manage status"
echo "   • Логи: event-registration-manage logs"
echo "   • Перезапуск: event-registration-manage restart"
echo "   • Обновление: event-registration-manage update"
echo ""
echo "📝 Следующие шаги:"
echo "   1. Проверьте SSL сертификат (Let's Encrypt)"
echo "   2. Обновите BOT_TOKEN в .env если нужно"
echo "   3. Протестируйте бота в Telegram"
echo ""

log "Скрипт развёртывания завершён успешно!" 