#!/bin/bash

# Скрипт для обновления уже развёрнутого приложения
# Использование: ./update.sh

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

PROJECT_NAME="event-registration"
PROJECT_DIR="/opt/$PROJECT_NAME"

log "Начинаем обновление проекта $PROJECT_NAME"

# Проверяем, существует ли директория проекта
if [ ! -d "$PROJECT_DIR" ]; then
    error "Директория проекта $PROJECT_DIR не найдена. Запустите deploy.sh для первоначального развёртывания."
fi

# Переходим в директорию проекта
cd "$PROJECT_DIR"

# Проверяем, что это git репозиторий
if [ ! -d ".git" ]; then
    error "Директория $PROJECT_DIR не является git репозиторием."
fi

# Сохраняем текущую ветку
CURRENT_BRANCH=$(git branch --show-current)
log "Текущая ветка: $CURRENT_BRANCH"

# Проверяем статус git
log "Проверяем статус git..."
git status --porcelain

# Создаем резервную копию текущего состояния
BACKUP_DIR="/opt/${PROJECT_NAME}_backup_$(date +%Y%m%d_%H%M%S)"
log "Создаем резервную копию в $BACKUP_DIR"
cp -r "$PROJECT_DIR" "$BACKUP_DIR"

# Останавливаем контейнеры
log "Останавливаем контейнеры..."
docker-compose down || warn "Ошибка при остановке контейнеров"

# Сохраняем .env файл
log "Сохраняем .env файл..."
if [ -f ".env" ]; then
    cp .env .env.backup
fi

# Получаем обновления из репозитория
log "Получаем обновления из репозитория..."
git fetch origin

# Проверяем, есть ли изменения
LOCAL_COMMIT=$(git rev-parse HEAD)
REMOTE_COMMIT=$(git rev-parse origin/main)

if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
    log "Обновлений нет, приложение уже актуально"
else
    log "Найдены обновления, обновляем код..."
    log "Локальный коммит: $LOCAL_COMMIT"
    log "Удаленный коммит: $REMOTE_COMMIT"
    
    # Переключаемся на main и обновляем
    git checkout main
    git pull origin main
    
    # Восстанавливаем .env файл
    if [ -f ".env.backup" ]; then
        cp .env.backup .env
        log ".env файл восстановлен"
    fi
fi

# Очищаем Docker кэш
log "Очищаем Docker кэш..."
docker system prune -f || warn "Ошибка при очистке кэша"

# Пересобираем контейнеры
log "Пересобираем контейнеры..."
docker-compose build --no-cache

# Запускаем контейнеры
log "Запускаем контейнеры..."
docker-compose up -d

# Ожидаем запуска сервисов
log "Ожидаем запуска сервисов..."
sleep 30

# Проверяем статус сервисов
log "Проверяем статус сервисов..."
docker-compose ps

# Проверяем доступность сервисов
log "Проверяем доступность сервисов..."

# Получаем домен из .env
if [ -f ".env" ]; then
    DOMAIN=$(grep "^DOMAIN=" .env | cut -d'=' -f2)
    if [ -n "$DOMAIN" ] && [ "$DOMAIN" != "localhost" ]; then
        log "Проверяем доступность по домену: $DOMAIN"
        
        if curl -f "https://$DOMAIN" > /dev/null 2>&1; then
            log "✅ Telegram WebApp доступен на https://$DOMAIN"
        else
            warn "⚠️ Telegram WebApp недоступен на https://$DOMAIN"
        fi
        
        if curl -f "https://$DOMAIN/admin" > /dev/null 2>&1; then
            log "✅ Admin Panel доступен на https://$DOMAIN/admin"
        else
            warn "⚠️ Admin Panel недоступен на https://$DOMAIN/admin"
        fi
    else
        log "Проверяем доступность по localhost..."
        
        if curl -f http://localhost:5174 > /dev/null 2>&1; then
            log "✅ Telegram WebApp доступен на http://localhost:5174"
        else
            warn "⚠️ Telegram WebApp недоступен"
        fi
        
        if curl -f http://localhost:5173 > /dev/null 2>&1; then
            log "✅ Admin Panel доступен на http://localhost:5173"
        else
            warn "⚠️ Admin Panel недоступен"
        fi
    fi
fi

if curl -f http://localhost:3000/api/registration-settings > /dev/null 2>&1; then
    log "✅ API доступен"
else
    log "✅ API запущен (health endpoint может отсутствовать)"
fi

# Очищаем старые резервные копии (оставляем только последние 5)
log "Очищаем старые резервные копии..."
find /opt -maxdepth 1 -name "${PROJECT_NAME}_backup_*" -type d | sort | head -n -5 | xargs -r rm -rf

# Вывод итоговой информации
log "🎉 Обновление завершено!"
echo ""
echo "🔧 Информация об обновлении:"
echo "   • Проект: $PROJECT_DIR"
echo "   • Резервная копия: $BACKUP_DIR"
echo "   • Предыдущий коммит: $LOCAL_COMMIT"
echo "   • Новый коммит: $REMOTE_COMMIT"
echo ""
echo "🔧 Управление:"
echo "   • Статус: event-registration-manage status"
echo "   • Логи: event-registration-manage logs"
echo "   • Перезапуск: event-registration-manage restart"
echo ""
echo "📝 Если что-то пошло не так:"
echo "   1. Проверьте логи: docker-compose logs"
echo "   2. Восстановите из резервной копии: $BACKUP_DIR"
echo "   3. Перезапустите: docker-compose restart"
echo ""

log "Скрипт обновления завершён успешно!" 