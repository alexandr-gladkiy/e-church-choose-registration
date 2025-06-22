#!/bin/bash

# Скрипт для полной локальной сборки и тестирования проекта
# Использование: ./build-local.sh

set -e

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

log "🚀 Начинаем полную локальную сборку проекта event-registration"

# Проверка Docker
log "Проверяем Docker..."
if ! command -v docker &> /dev/null; then
    error "Docker не установлен! Установите Docker и попробуйте снова."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    error "Docker Compose не установлен! Установите Docker Compose и попробуйте снова."
    exit 1
fi

# Остановка существующих контейнеров
log "Останавливаем существующие контейнеры..."
docker-compose down --remove-orphans || true

# Очистка Docker
log "Очищаем Docker кэш..."
docker system prune -f || true

# Создание .env для локального тестирования
log "Создаём .env файл для локального тестирования..."
cat > .env << EOF
BOT_TOKEN=test_token_123456789
DOMAIN=http://localhost
EOF

# Полная пересборка всех сервисов
log "Пересобираем все сервисы..."
docker-compose build --no-cache

# Запуск сервисов
log "Запускаем все сервисы..."
docker-compose up -d

# Ожидание запуска
log "Ожидаем запуска сервисов..."
sleep 45

# Проверка статуса
log "Проверяем статус сервисов..."
docker-compose ps

# Проверка доступности сервисов
log "Проверяем доступность сервисов..."

# Telegram WebApp
info "Тестируем Telegram WebApp..."
if curl -f http://localhost:5174 > /dev/null 2>&1; then
    log "✅ Telegram WebApp доступен на http://localhost:5174"
else
    warn "⚠️ Telegram WebApp недоступен"
fi

# Admin Panel
info "Тестируем Admin Panel..."
if curl -f http://localhost:5173 > /dev/null 2>&1; then
    log "✅ Admin Panel доступен на http://localhost:5173"
else
    warn "⚠️ Admin Panel недоступен"
fi

# API
info "Тестируем API..."
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    log "✅ API доступен на http://localhost:3000"
else
    warn "⚠️ API недоступен"
fi

# Тестирование API endpoints
log "Тестируем API endpoints..."

# Тест настроек регистрации
info "Тестируем /api/registration-settings..."
if curl -f http://localhost:3000/api/registration-settings > /dev/null 2>&1; then
    log "✅ API /api/registration-settings работает"
else
    warn "⚠️ API /api/registration-settings недоступен"
fi

# Тест CORS для admin-app
info "Тестируем CORS для admin-app..."
if curl -H "Origin: http://localhost:5173" -H "Access-Control-Request-Method: GET" \
   -H "Access-Control-Request-Headers: X-Requested-With" \
   -X OPTIONS http://localhost:3000/api/registration-settings > /dev/null 2>&1; then
    log "✅ CORS для admin-app работает"
else
    warn "⚠️ CORS для admin-app может не работать"
fi

# Тест CORS для telegram-app
info "Тестируем CORS для telegram-app..."
if curl -H "Origin: http://localhost:5174" -H "Access-Control-Request-Method: GET" \
   -H "Access-Control-Request-Headers: X-Requested-With" \
   -X OPTIONS http://localhost:3000/api/registration-settings > /dev/null 2>&1; then
    log "✅ CORS для telegram-app работает"
else
    warn "⚠️ CORS для telegram-app может не работать"
fi

# Проверка логов
log "Проверяем логи сервисов..."

# Логи backend-api
info "Логи backend-api (последние 10 строк):"
docker-compose logs backend-api --tail=10

# Логи admin-app
info "Логи admin-app (последние 10 строк):"
docker-compose logs admin-app --tail=10

# Логи telegram-app
info "Логи telegram-app (последние 10 строк):"
docker-compose logs telegram-app --tail=10

# Логи telegram-bot
info "Логи telegram-bot (последние 10 строк):"
docker-compose logs telegram-bot --tail=10

# Тестирование функциональности
log "Тестируем функциональность..."

# Тест базы данных
info "Проверяем подключение к базе данных..."
if docker-compose exec postgres pg_isready -U postgres > /dev/null 2>&1; then
    log "✅ База данных PostgreSQL работает"
else
    warn "⚠️ Проблемы с базой данных PostgreSQL"
fi

# Тест API ответов
info "Тестируем API ответы..."
REGISTRATION_SETTINGS=$(curl -s http://localhost:3000/api/registration-settings 2>/dev/null || echo "ERROR")
if [[ "$REGISTRATION_SETTINGS" != "ERROR" ]]; then
    log "✅ API возвращает данные настроек регистрации"
    echo "   Настройки: $REGISTRATION_SETTINGS"
else
    warn "⚠️ API не возвращает данные настроек"
fi

# Финальная проверка
log "🎉 Локальная сборка завершена!"
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
echo "   • Перезапуск: docker-compose restart"
echo ""
echo "📝 Для тестирования в браузере:"
echo "   1. Откройте http://localhost:5174 - Telegram WebApp"
echo "   2. Откройте http://localhost:5173 - Admin Panel"
echo "   3. Проверьте http://localhost:3000/api/registration-settings - API"
echo ""
echo "🤖 Для тестирования бота:"
echo "   - Используйте токен: test_token_123456789"
echo "   - WebApp URL: http://localhost:5174"
echo ""
echo "📊 Мониторинг:"
echo "   • docker-compose logs -f backend-api"
echo "   • docker-compose logs -f admin-app"
echo "   • docker-compose logs -f telegram-app"
echo "   • docker-compose logs -f telegram-bot" 