<template>
  <div class="success-message">
    <div class="success-icon">✅</div>
    <h2>Регистрация успешно завершена!</h2>
    <p>Спасибо за регистрацию. Мы свяжемся с вами в Telegram.</p>
    <button class="reset-btn" @click="$emit('reset-form')">Зарегистрировать еще одного участника</button>
  </div>
</template>

<script>
export default {
  name: 'SuccessMessage',
  emits: ['reset-form']
}
</script>

<style scoped>
.success-message {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 0 0 20px 20px;
  padding: 40px;
  box-shadow: 
    0 20px 40px rgba(0, 0, 0, 0.3),
    0 0 0 1px rgba(255, 255, 255, 0.1);
  width: 100%;
  max-width: 800px;
  margin: 0;
  position: relative;
  z-index: 1;
  text-align: center;
}

.success-icon {
  font-size: 4rem;
  margin-bottom: 20px;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.3));
  animation: bounce 0.6s ease-out;
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

.success-message h2 {
  color: #2c3e50;
  margin-bottom: 15px;
  font-size: 1.8rem;
}

.success-message p {
  color: #7f8c8d;
  margin-bottom: 30px;
  font-size: 1.1rem;
  line-height: 1.5;
}

.reset-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 15px 30px;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.3);
}

.reset-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
}

@media (max-width: 768px) {
  .success-message {
    margin: 0;
    padding: 20px;
  }
  .success-message h2 {
    font-size: 1.5rem;
  }
  .success-message p {
    font-size: 1rem;
  }
}
</style> 