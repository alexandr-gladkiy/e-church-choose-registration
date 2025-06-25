#!/bin/bash

echo "🔧 Исправляем проблему с редиректами в nginx..."

# Проверяем, что мы на сервере
if [ ! -f "/etc/nginx/sites-available/choose.su" ]; then
    echo "❌ Файл конфигурации nginx не найден. Убедитесь, что скрипт запущен на сервере."
    exit 1
fi

# Создаем резервную копию
echo "📋 Создаем резервную копию текущей конфигурации..."
cp /etc/nginx/sites-available/choose.su /etc/nginx/sites-available/choose.su.backup.$(date +%Y%m%d_%H%M%S)

# Копируем исправленную конфигурацию
echo "🔧 Применяем исправленную конфигурацию..."
cp nginx-fixed.conf /etc/nginx/sites-available/choose.su

# Проверяем синтаксис nginx
echo "✅ Проверяем синтаксис nginx..."
nginx -t

if [ $? -eq 0 ]; then
    echo "🔄 Перезагружаем nginx..."
    systemctl reload nginx
    echo "✅ Конфигурация nginx успешно обновлена!"
    echo "🌐 Админ панель должна быть доступна по адресу: https://choose.su/admin/"
else
    echo "❌ Ошибка в конфигурации nginx. Восстанавливаем резервную копию..."
    cp /etc/nginx/sites-available/choose.su.backup.* /etc/nginx/sites-available/choose.su
    systemctl reload nginx
    exit 1
fi 