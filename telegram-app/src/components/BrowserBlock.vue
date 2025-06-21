<template>
  <div class="browser-block">
    <div class="block-content">
      <div class="icon">📱</div>
      <h2>Это приложение предназначено для Telegram</h2>
      <p>Для регистрации на мероприятие, пожалуйста, используйте Telegram бота.</p>
      
      <div class="telegram-info">
        <p><strong>Как получить доступ:</strong></p>
        <ol>
          <li>Найдите нашего бота в Telegram</li>
          <li>Отправьте команду <code>/start</code></li>
          <li>Нажмите кнопку "Открыть регистрацию"</li>
        </ol>
      </div>
      
      <div class="contact-info">
        <p>Если у вас возникли вопросы, обратитесь к организаторам мероприятия.</p>
      </div>
      
      <div v-if="showAdminOverride" class="admin-override">
        <button @click="enableRegistration" class="admin-btn">
          🔓 Включить регистрацию (только для администраторов)
        </button>
        <button @click="refreshSettings" class="refresh-btn">
          🔄 Обновить настройки
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'

export default {
  name: 'BrowserBlock',
  props: {
    showAdminOverride: {
      type: Boolean,
      default: false
    }
  },
  emits: ['enable-registration', 'refresh-settings'],
  setup(props, { emit }) {
    const enableRegistration = () => {
      emit('enable-registration')
    }

    const refreshSettings = () => {
      emit('refresh-settings')
    }

    return {
      enableRegistration,
      refreshSettings
    }
  }
}
</script>

<style scoped>
.browser-block {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 40px;
  box-shadow: 
    0 20px 40px rgba(0, 0, 0, 0.3),
    0 0 0 1px rgba(255, 255, 255, 0.1);
  width: 100%;
  max-width: 600px;
  margin: 0 auto;
  text-align: center;
}

.block-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}

.icon {
  font-size: 4rem;
  margin-bottom: 10px;
}

h2 {
  color: #333;
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
}

p {
  color: #666;
  margin: 0;
  line-height: 1.6;
  font-size: 1rem;
}

.telegram-info {
  background: rgba(102, 126, 234, 0.1);
  border: 2px solid rgba(102, 126, 234, 0.2);
  border-radius: 12px;
  padding: 20px;
  margin: 20px 0;
  text-align: left;
  width: 100%;
}

.telegram-info p {
  margin-bottom: 15px;
  font-weight: 600;
  color: #333;
}

.telegram-info ol {
  margin: 0;
  padding-left: 20px;
  color: #666;
}

.telegram-info li {
  margin-bottom: 8px;
  line-height: 1.5;
}

.telegram-info code {
  background: rgba(102, 126, 234, 0.2);
  color: #667eea;
  padding: 2px 6px;
  border-radius: 4px;
  font-family: monospace;
  font-weight: 600;
}

.contact-info {
  background: rgba(255, 193, 7, 0.1);
  border: 2px solid rgba(255, 193, 7, 0.2);
  border-radius: 12px;
  padding: 15px;
  margin: 10px 0;
}

.contact-info p {
  color: #856404;
  font-weight: 500;
}

.admin-override {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 2px solid rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  gap: 10px;
  align-items: center;
}

.admin-btn {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(220, 53, 69, 0.3);
}

.admin-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(220, 53, 69, 0.4);
}

.admin-btn:active {
  transform: translateY(0);
}

.refresh-btn {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(23, 162, 184, 0.3);
}

.refresh-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(23, 162, 184, 0.4);
}

.refresh-btn:active {
  transform: translateY(0);
}

/* Адаптивность для мобильных устройств */
@media (max-width: 768px) {
  .browser-block {
    padding: 20px;
    margin: 10px;
  }
  
  h2 {
    font-size: 1.3rem;
  }
  
  .icon {
    font-size: 3rem;
  }
}
</style> 