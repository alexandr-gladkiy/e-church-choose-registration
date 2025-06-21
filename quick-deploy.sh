#!/bin/bash

# Быстрый деплой для обновления конфигурации
# Использование: ./quick-deploy.sh [DOMAIN] [BOT_TOKEN]

set -e

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

# Проверка аргументов
if [ $# -lt 2 ]; then
    echo "Использование: $0 [DOMAIN] [BOT_TOKEN]"
    echo "Пример: $0 choose.su 1234567890:ABCdefGHIjklMNOpqrsTUVwxyz"
    exit 1
fi

DOMAIN=$1
BOT_TOKEN=$2

log "Обновляем конфигурацию для домена: $DOMAIN"

# Обновление .env файла
log "Обновляем .env файл..."
cat > .env << EOF
BOT_TOKEN=$BOT_TOKEN
DOMAIN=https://$DOMAIN
EOF

# Остановка контейнеров
log "Останавливаем контейнеры..."
docker-compose down

# Пересборка и запуск
log "Пересобираем и запускаем контейнеры..."
docker-compose build --no-cache
docker-compose up -d

# Ожидание запуска
log "Ожидаем запуска сервисов..."
sleep 30

# Проверка статуса
log "Проверяем статус сервисов..."
docker-compose ps

log "✅ Обновление завершено!"
echo ""
echo "🔧 Доступные URL:"
echo "   • Telegram WebApp: https://$DOMAIN"
echo "   • Admin Panel: https://$DOMAIN/admin"
echo "   • API: https://$DOMAIN/api"
echo ""
echo "🔧 Управление:"
echo "   • Статус: docker-compose ps"
echo "   • Логи: docker-compose logs -f"
echo "   • Перезапуск: docker-compose restart" 