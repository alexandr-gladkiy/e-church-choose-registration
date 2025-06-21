#!/bin/bash

# Скрипт для тестирования новой конфигурации локально
# Использование: ./test-local.sh

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

log "Тестируем новую конфигурацию локально..."

# Создание .env для локального тестирования
log "Создаём .env файл для локального тестирования..."
cat > .env << EOF
BOT_TOKEN=test_token_123
DOMAIN=http://localhost
EOF

# Остановка существующих контейнеров
log "Останавливаем существующие контейнеры..."
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

# Тестирование доступности
log "Тестируем доступность сервисов..."

# Telegram WebApp
if curl -f http://localhost:5174 > /dev/null 2>&1; then
    log "✅ Telegram WebApp доступен на http://localhost:5174"
else
    warn "⚠️ Telegram WebApp недоступен"
fi

# Admin Panel
if curl -f http://localhost:5173 > /dev/null 2>&1; then
    log "✅ Admin Panel доступен на http://localhost:5173"
else
    warn "⚠️ Admin Panel недоступен"
fi

# API
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    log "✅ API доступен на http://localhost:3000"
else
    warn "⚠️ API недоступен"
fi

# Тестирование API endpoints
log "Тестируем API endpoints..."

# Тест настроек регистрации
if curl -f http://localhost:3000/api/registration-settings > /dev/null 2>&1; then
    log "✅ API /api/registration-settings работает"
else
    warn "⚠️ API /api/registration-settings недоступен"
fi

# Тест CORS для admin-app
log "Тестируем CORS для admin-app..."
if curl -H "Origin: http://localhost:5173" -H "Access-Control-Request-Method: GET" \
   -H "Access-Control-Request-Headers: X-Requested-With" \
   -X OPTIONS http://localhost:3000/api/registration-settings > /dev/null 2>&1; then
    log "✅ CORS для admin-app работает"
else
    warn "⚠️ CORS для admin-app может не работать"
fi

# Тест CORS для telegram-app
log "Тестируем CORS для telegram-app..."
if curl -H "Origin: http://localhost:5174" -H "Access-Control-Request-Method: GET" \
   -H "Access-Control-Request-Headers: X-Requested-With" \
   -X OPTIONS http://localhost:3000/api/registration-settings > /dev/null 2>&1; then
    log "✅ CORS для telegram-app работает"
else
    warn "⚠️ CORS для telegram-app может не работать"
fi

log "✅ Локальное тестирование завершено!"
echo ""
echo "🔧 Доступные URL для тестирования:"
echo "   • Telegram WebApp: http://localhost:5174"
echo "   • Admin Panel: http://localhost:5173"
echo "   • API: http://localhost:3000"
echo ""
echo "🔧 Команды для управления:"
echo "   • Статус: docker-compose ps"
echo "   • Логи: docker-compose logs -f"
echo "   • Остановка: docker-compose down"
echo ""
echo "📝 Для продакшена используйте:"
echo "   ./deploy.sh [GITHUB_REPO_URL] [BOT_TOKEN] [DOMAIN]" 