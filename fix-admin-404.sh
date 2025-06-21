#!/bin/bash

# Скрипт для исправления ошибки 404 в admin панели
# Использование: ./fix-admin-404.sh

set -e

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

log "Исправляем ошибку 404 в admin панели..."

# 1. Остановка контейнеров
log "Останавливаем контейнеры..."
docker-compose down

# 2. Пересборка admin-app
log "Пересобираем admin-app..."
docker-compose build --no-cache admin-app

# 3. Запуск контейнеров
log "Запускаем контейнеры..."
docker-compose up -d

# 4. Ожидание запуска
log "Ожидаем запуска сервисов..."
sleep 30

# 5. Проверка статуса
log "Проверяем статус сервисов..."
docker-compose ps

# 6. Проверка доступности admin-app
log "Проверяем доступность admin-app..."
if curl -f http://localhost:5173 > /dev/null 2>&1; then
    log "✅ Admin-app доступен локально"
else
    warn "⚠️ Admin-app недоступен локально"
fi

# 7. Проверка логов admin-app
log "Проверяем логи admin-app..."
docker-compose logs admin-app --tail=20

log "✅ Исправление завершено!"
echo ""
echo "🔧 Проверьте доступность:"
echo "   • Локально: http://localhost:5173"
echo "   • Через nginx: https://choose.su/admin"
echo ""
echo "📝 Если проблема осталась, проверьте:"
echo "   1. Логи nginx: sudo nginx -t && sudo systemctl status nginx"
echo "   2. Логи admin-app: docker-compose logs admin-app -f"
echo "   3. Конфигурацию nginx: sudo cat /etc/nginx/sites-available/event-registration" 