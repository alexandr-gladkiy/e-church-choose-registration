# 🌐 Поддержка поддоменов в event-registration

## Архитектура поддоменов

Проект поддерживает развёртывание на поддоменах:

- **choose.su** - Telegram WebApp (основное приложение)
- **admin.choose.su** - Админ-панель
- **api.choose.su** - Backend API

## Исправления для поддержки поддоменов

### 1. Nginx конфигурация (deploy.sh)

**Проблема:** Каждый поддомен использовал отдельный SSL сертификат
**Решение:** Все поддомены используют один SSL сертификат основного домена

```nginx
# Все поддомены используют сертификат основного домена
ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
```

### 2. Переменные окружения (.env)

**Добавлены переменные:**
```bash
DOMAIN=https://choose.su
ADMIN_DOMAIN=https://admin.choose.su
API_DOMAIN=https://api.choose.su
```

### 3. Docker Compose (docker-compose.yaml)

**Обновлены переменные окружения:**
```yaml
admin-app:
  environment:
    VITE_API_URL: ${API_DOMAIN:-http://localhost:3000/api}

telegram-app:
  environment:
    VITE_API_URL: ${API_DOMAIN:-http://localhost:3000/api}

telegram-bot:
  environment:
    WEBAPP_URL: ${DOMAIN:-http://localhost:5174}

backend-api:
  environment:
    DOMAIN: ${DOMAIN}
    ADMIN_DOMAIN: ${ADMIN_DOMAIN}
    API_DOMAIN: ${API_DOMAIN}
```

### 4. CORS настройки (backend-api/index.js)

**Проблема:** CORS был настроен только для localhost
**Решение:** Динамическое добавление поддоменов в разрешённые origins

```javascript
const allowedOrigins = [
  'http://localhost:5173', 
  'http://localhost:5174',
  'https://localhost:5173',
  'https://localhost:5174'
];

// Добавляем поддомены из переменных окружения
if (process.env.DOMAIN) {
  const domain = process.env.DOMAIN.replace('https://', '').replace('http://', '');
  const adminDomain = process.env.ADMIN_DOMAIN?.replace('https://', '').replace('http://', '') || `admin.${domain}`;
  
  allowedOrigins.push(
    `https://${domain}`,
    `https://${adminDomain}`,
    `http://${domain}`,
    `http://${adminDomain}`
  );
}
```

### 5. SSL сертификаты (certbot)

**Настройка:** Один сертификат для всех поддоменов
```bash
sudo certbot --nginx --non-interactive --agree-tos --redirect \
  -m admin@choose.su \
  -d choose.su \
  -d admin.choose.su \
  -d api.choose.su
```

## Проверка работоспособности

### 1. DNS записи
Убедитесь, что все поддомены указывают на IP сервера:
```
choose.su        A  YOUR_SERVER_IP
admin.choose.su  A  YOUR_SERVER_IP
api.choose.su    A  YOUR_SERVER_IP
```

### 2. SSL сертификаты
```bash
sudo certbot certificates
```

### 3. Nginx конфигурация
```bash
sudo nginx -t
sudo systemctl status nginx
```

### 4. Проверка доступности
```bash
# Telegram WebApp
curl -I https://choose.su

# Admin Panel
curl -I https://admin.choose.su

# API
curl -I https://api.choose.su
```

## Устранение проблем

### Проблема: CORS ошибки
**Решение:** Проверьте, что поддомены добавлены в allowedOrigins в backend-api/index.js

### Проблема: SSL сертификат не работает
**Решение:** 
```bash
sudo certbot renew --dry-run
sudo systemctl reload nginx
```

### Проблема: Поддомены не доступны
**Решение:** Проверьте DNS записи и nginx конфигурацию

## Тестирование

### Локальное тестирование
```bash
# Добавьте в /etc/hosts для локального тестирования
127.0.0.1 choose.su
127.0.0.1 admin.choose.su
127.0.0.1 api.choose.su
```

### Продакшн тестирование
1. Откройте https://choose.su - должен открыться Telegram WebApp
2. Откройте https://admin.choose.su - должна открыться админ-панель
3. Откройте https://api.choose.su - должен ответить API

---

**Готово!** Проект полностью поддерживает развёртывание на поддоменах. 🚀 