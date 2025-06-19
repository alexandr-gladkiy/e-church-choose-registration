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
      <div class="user-info-grid">
        <div class="info-row">
          <div class="info-label">Полное имя:</div>
          <div class="info-value">{{ user.fullName }}</div>
        </div>
        <div class="info-row">
          <div class="info-label">Город:</div>
          <div class="info-value">{{ user.city }}</div>
        </div>
        <div class="info-row">
          <div class="info-label">Название Церкви:</div>
          <div class="info-value">{{ user.churchName }}</div>
        </div>
        <div v-if="user.comments" class="info-row">
          <div class="info-label">Комментарии:</div>
          <div class="info-value">{{ user.comments }}</div>
        </div>
        <div class="info-row">
          <div class="info-label">Нужно расселение:</div>
          <div class="info-value">
            <span :class="user.needAccommodation ? 'yes' : 'no'">
              {{ user.needAccommodation ? 'Да' : 'Нет' }}
            </span>
          </div>
        </div>
        <div v-if="user.telegramUsername" class="info-row">
          <div class="info-label">Telegram:</div>
          <div class="info-value">@{{ user.telegramUsername }}</div>
        </div>
        <div class="info-row">
          <div class="info-label">Дата регистрации:</div>
          <div class="info-value">{{ formatDate(user.registrationDate) }}</div>
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

.user-info-grid {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.info-row {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 8px;
  background: rgba(102,126,234,0.1);
  padding: 20px;
  border-radius: 12px;
  border: 1px solid rgba(102,126,234,0.2);
  width: 100%;
}

.info-label {
  color: #333;
  font-size: 1.05rem;
  font-weight: 600;
  min-width: 120px;
}

.info-value {
  color: #667eea;
  font-size: 1.1rem;
  font-weight: 700;
  flex: 1;
}

.info-value .yes {
  color: #28a745;
  font-weight: 700;
}

.info-value .no {
  color: #dc3545;
  font-weight: 700;
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
  
  .cancel-btn {
    padding: 12px 20px;
    font-size: 1rem;
  }
}
</style> 