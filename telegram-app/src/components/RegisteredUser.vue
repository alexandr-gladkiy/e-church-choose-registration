<template>
  <div class="registered-user-container">
    <div class="congratulations-block">
      <div class="congratulations-icon">🎉</div>
      <h2 class="congratulations-title">Поздравляем с регистрацией!</h2>
      <p class="congratulations-text">
        Вы успешно зарегистрировались на конференцию. Мы рады, что вы присоединились к нам!
      </p>
    </div>

    <div class="user-info-block">
      <h3 class="user-info-title">Ваши данные регистрации</h3>
      <div class="user-info-content">
        <div class="info-section">
          <h4 class="info-section-title">Основная информация</h4>
          <p class="info-text"><strong>Ф.И.О.:</strong> {{ user.full_name }}</p>
          <p class="info-text"><strong>Город:</strong> {{ user.city }}</p>
          <p class="info-text"><strong>Церковь:</strong> {{ user.church_name }}</p>
          <p v-if="user.phone" class="info-text"><strong>Телефон:</strong> {{ user.phone }}</p>
        </div>

        <div v-if="user.comments" class="info-section">
          <h4 class="info-section-title">Дополнительная информация</h4>
          <p class="info-text"><strong>Комментарии:</strong> {{ user.comments }}</p>
        </div>

        <div class="info-section">
          <h4 class="info-section-title">Детали регистрации</h4>
          <p class="info-text">
            <strong>Расселение:</strong> 
            <span :class="user.need_accommodation ? 'status-yes' : 'status-no'">
              {{ user.need_accommodation ? 'Нужно' : 'Не нужно' }}
            </span>
          </p>
          <p v-if="user.telegram_id" class="info-text">
            <strong>Telegram ID:</strong> {{ user.telegram_id }}
          </p>
          <p v-if="user.telegram_username && user.telegram_username !== 'testuser'" class="info-text">
            <strong>Telegram:</strong> @{{ user.telegram_username }}
          </p>
          <p class="info-text">
            <strong>Дата регистрации:</strong> {{ formatDate(user.registration_date) }}
          </p>
        </div>
      </div>
    </div>

    <div class="actions-block">
      <a href="#" class="terms-link" target="_blank">Условия участия в конференции</a>
      <button class="cancel-btn" @click="cancelRegistration" :disabled="isLoading">
        <span v-if="!isLoading">Отменить регистрацию</span>
        <span v-else class="btn-loading">
          <div class="spinner"></div>
          Отмена...
        </span>
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RegisteredUser',
  props: {
    user: { type: Object, required: true },
    isLoading: { type: Boolean, default: false }
  },
  emits: ['cancel-registration'],
  setup(props, { emit }) {
    const formatDate = (dateString) => {
      if (!dateString) return ''
      return new Date(dateString).toLocaleDateString('ru-RU', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
    const cancelRegistration = () => {
      emit('cancel-registration')
    }
    return { formatDate, cancelRegistration }
  }
}
</script>

<style scoped>
.registered-user-container {
  background: rgba(255,255,255,0.95);
  border-radius: 0 0 20px 20px;
  padding: 40px;
  width: 100%;
  max-width: 800px;
  margin: 0;
  box-shadow: 0 20px 40px rgba(0,0,0,0.3), 0 0 0 1px rgba(255,255,255,0.1);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 32px;
}

.congratulations-block {
  text-align: center;
  width: 100%;
}

.congratulations-icon {
  font-size: 4rem;
  margin-bottom: 16px;
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 20%, 50%, 80%, 100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-10px);
  }
  60% {
    transform: translateY(-5px);
  }
}

.congratulations-title {
  color: #333;
  font-size: 1.8rem;
  font-weight: 700;
  margin: 0 0 12px 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.congratulations-text {
  color: #666;
  font-size: 1.1rem;
  line-height: 1.6;
  margin: 0;
  max-width: 500px;
}

.user-info-block {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}

.user-info-title {
  color: #333;
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0 0 12px 0;
}

.user-info-content {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.info-section {
  background: rgba(102,126,234,0.05);
  border: 1px solid rgba(102,126,234,0.1);
  border-radius: 12px;
  padding: 20px;
  width: 100%;
}

.info-section-title {
  color: #333;
  font-size: 1.2rem;
  font-weight: 700;
  margin: 0 0 16px 0;
  padding-bottom: 8px;
  border-bottom: 2px solid rgba(102,126,234,0.2);
}

.info-text {
  color: #555;
  font-size: 1rem;
  line-height: 1.6;
  margin: 8px 0;
}

.info-text strong {
  color: #333;
  font-weight: 600;
}

.info-text .status-yes {
  color: #28a745;
  font-weight: 600;
}

.info-text .status-no {
  color: #6c757d;
  font-weight: 600;
}

.actions-block {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 18px;
  width: 100%;
}

.terms-link {
  color: #667eea;
  text-decoration: none;
  font-size: 1.1rem;
  font-weight: 600;
  transition: all 0.3s ease;
}

.terms-link:hover {
  text-decoration: underline;
}

.cancel-btn {
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a52 100%);
  color: white;
  border: none;
  padding: 16px 32px;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 8px 25px rgba(255,107,107,0.3);
}

.cancel-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 30px rgba(255,107,107,0.4);
}

.cancel-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  transform: none;
}

.btn-loading {
  display: flex;
  align-items: center;
  gap: 12px;
  justify-content: center;
}

.spinner {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(255,255,255,0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

@media (max-width: 768px) {
  .registered-user-container {
    padding: 20px;
    gap: 20px;
  }
  
  .congratulations-icon {
    font-size: 3rem;
  }
  
  .congratulations-title {
    font-size: 1.5rem;
  }
  
  .congratulations-text {
    font-size: 1rem;
  }
  
  .user-info-title {
    font-size: 1.3rem;
  }
  
  .info-section {
    padding: 16px;
  }
  
  .info-section-title {
    font-size: 1.1rem;
    margin-bottom: 12px;
  }
  
  .info-text {
    font-size: 0.95rem;
  }
  
  .cancel-btn {
    padding: 12px 20px;
    font-size: 1rem;
  }
}
</style> 