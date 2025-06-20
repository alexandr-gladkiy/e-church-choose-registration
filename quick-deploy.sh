#!/bin/bash

# Быстрый скрипт развёртывания event-registration
# Использование: ./quick-deploy.sh [GITHUB_REPO_URL] [BOT_TOKEN]

set -e

# Цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

# Проверка аргументов
if [ $# -lt 2 ]; then
    echo "Использование: $0 <GITHUB_REPO_URL> <BOT_TOKEN>"
    echo "Пример: $0 https://github.com/username/event-registration.git 1234567890:ABCdefGHIjklMNOpqrsTUVwxyz"
    exit 1
fi

GITHUB_REPO_URL=$1
BOT_TOKEN=$2
PROJECT_NAME="event-registration"

log "🚀 Быстрое развёртывание event-registration"

# Обновление системы
log "Обновляем систему..."
sudo apt-get update -y

# Установка Docker
log "Проверяем Docker..."
if ! command -v docker &> /dev/null; then
    log "Устанавливаем Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    log "Docker установлен. Перезагрузитесь или выполните: newgrp docker"
fi

# Установка Docker Compose
log "Проверяем Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    log "Устанавливаем Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Создание директории
log "Создаём директорию проекта..."
sudo mkdir -p /opt/$PROJECT_NAME
sudo chown $USER:$USER /opt/$PROJECT_NAME
cd /opt/$PROJECT_NAME

# Клонирование проекта
log "Клонируем проект..."
if [ -d ".git" ]; then
    log "Проект существует, обновляем..."
    git pull origin main
else
    git clone $GITHUB_REPO_URL .
fi

# Создание .env
log "Создаём .env файл..."
cat > .env << EOF
BOT_TOKEN=$BOT_TOKEN
EOF

# Сборка и запуск
log "Собираем и запускаем контейнеры..."
docker-compose down --remove-orphans || true
docker-compose build --no-cache || {
    log "Ошибка сборки, пробуем без --no-cache..."
    docker-compose build
}
docker-compose up -d

# Ожидание запуска
log "Ожидаем запуска сервисов..."
sleep 30

# Проверка
log "Проверяем статус..."
docker-compose ps

# Создание скрипта управления
log "Создаём скрипт управления..."
cat > /usr/local/bin/event-manage << 'EOF'
#!/bin/bash
cd /opt/event-registration
case "$1" in
    status) docker-compose ps ;;
    logs) docker-compose logs -f ;;
    restart) docker-compose restart ;;
    stop) docker-compose down ;;
    start) docker-compose up -d ;;
    update) git pull && docker-compose build && docker-compose up -d ;;
    *) echo "Использование: event-manage {status|logs|restart|stop|start|update}" ;;
esac
EOF

chmod +x /usr/local/bin/event-manage

# Результат
log "✅ Развёртывание завершено!"
echo ""
echo "📋 Доступные сервисы:"
echo "   • Telegram WebApp: http://$(hostname -I | awk '{print $1}'):5174"
echo "   • Admin Panel: http://$(hostname -I | awk '{print $1}'):5173"
echo "   • API: http://$(hostname -I | awk '{print $1}'):3000"
echo ""
echo "🔧 Управление:"
echo "   • event-manage status  - статус"
echo "   • event-manage logs    - логи"
echo "   • event-manage restart - перезапуск"
echo ""
echo "📝 Следующие шаги:"
echo "   1. Настройте домен и SSL"
echo "   2. Протестируйте бота в Telegram"
echo "   3. Настройте nginx для проксирования"
echo ""

log "🎉 Готово к использованию!" 