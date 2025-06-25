<template>
  <div class="container">
    <HeaderBlock />
    <div class="block-wrapper"><ImageCarousel /></div>
    <div class="block-wrapper"><InfoBlock /></div>
    
    <!-- Форма регистрации - доступна всегда -->
    <div class="block-wrapper">
      <RegistrationForm 
        :telegram-user="telegramUser"
        @telegram-user-received="handleTelegramUserReceived"
      />
    </div>
  </div>
</template>

<script>
import { ref, onMounted, onUnmounted } from 'vue'
import HeaderBlock from './components/HeaderBlock.vue'
import ImageCarousel from './components/ImageCarousel.vue'
import InfoBlock from './components/InfoBlock.vue'
import RegistrationForm from './components/RegistrationForm.vue'

export default {
  name: 'App',
  components: {
    HeaderBlock,
    ImageCarousel,
    InfoBlock,
    RegistrationForm
  },
  setup() {
    const telegramUser = ref(null)
    const isWebApp = ref(false)
    const loading = ref(true)

    // Определение WebApp
    const detectWebApp = () => {
      isWebApp.value = !!(window.Telegram && window.Telegram.WebApp)
    }

    const handleTelegramUserReceived = (user) => {
      telegramUser.value = user
      console.log('Telegram WebApp user data:', telegramUser.value)
    }

    onMounted(async () => {
      detectWebApp()
      
      // Инициализация Telegram Web App
      if (window.Telegram && window.Telegram.WebApp) {
        const tg = window.Telegram.WebApp
        tg.ready()
        tg.expand()
        
        // Получаем данные пользователя
        if (tg.initDataUnsafe && tg.initDataUnsafe.user) {
          telegramUser.value = tg.initDataUnsafe.user
          console.log('Telegram WebApp user data:', telegramUser.value)
        }
      } else {
        // Для тестирования в браузере создаем тестовые данные
        // Можно переопределить через URL параметры
        const urlParams = new URLSearchParams(window.location.search)
        const testUserId = urlParams.get('test_user_id') || '123456789'
        const testUsername = urlParams.get('test_username') || 'testuser'
        const testFirstName = urlParams.get('test_first_name') || 'Тестовый'
        const testLastName = urlParams.get('test_last_name') || 'Пользователь'
        
        telegramUser.value = {
          id: parseInt(testUserId),
          username: testUsername,
          first_name: testFirstName,
          last_name: testLastName,
          is_bot: false
        }
        console.log('Test Telegram user data:', telegramUser.value)
      }

      loading.value = false
    })

    return {
      telegramUser,
      isWebApp,
      loading,
      handleTelegramUserReceived
    }
  }
}
</script>

<style scoped>
.container {
  min-height: 100vh;
  background: 
    linear-gradient(135deg, rgba(20, 20, 35, 0.95) 0%, rgba(40, 30, 60, 0.95) 100%),
    url('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1920&q=80');
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
  background-repeat: no-repeat;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  padding: 20px;
  position: relative;
}

.container::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: 
    radial-gradient(circle at 20% 80%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
    radial-gradient(circle at 80% 20%, rgba(255, 119, 198, 0.3) 0%, transparent 50%),
    radial-gradient(circle at 40% 40%, rgba(120, 219, 255, 0.2) 0%, transparent 50%);
  pointer-events: none;
  z-index: 0;
}

.block-wrapper {
  width: 100%;
  max-width: 800px;
  margin-left: auto;
  margin-right: auto;
}

/* Адаптивность для мобильных устройств */
@media (max-width: 768px) {
  .container {
    padding: 10px;
  }
}
</style> 