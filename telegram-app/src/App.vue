<template>
  <div class="container">
    <HeaderBlock />
    <div class="block-wrapper"><ImageCarousel /></div>
    <div class="block-wrapper"><InfoBlock /></div>
    
    <!-- Заглушка для браузера или основная форма -->
    <div class="block-wrapper">
      <BrowserBlock 
        v-if="showBrowserBlock"
        :show-admin-override="isAdmin"
        @enable-registration="enableRegistration"
        @refresh-settings="refreshSettings"
      />
      <RegistrationForm 
        v-else
        :telegram-user="telegramUser"
      />
    </div>
  </div>
</template>

<script>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import HeaderBlock from './components/HeaderBlock.vue'
import ImageCarousel from './components/ImageCarousel.vue'
import InfoBlock from './components/InfoBlock.vue'
import RegistrationForm from './components/RegistrationForm.vue'
import BrowserBlock from './components/BrowserBlock.vue'
import api from './api'

export default {
  name: 'App',
  components: {
    HeaderBlock,
    ImageCarousel,
    InfoBlock,
    RegistrationForm,
    BrowserBlock
  },
  setup() {
    const telegramUser = ref(null)
    const isWebApp = ref(false)
    const browserOverride = ref(false)
    const isAdmin = ref(false)
    const browserAccessEnabled = ref(false)

    // Определяем, нужно ли показывать заглушку
    const showBrowserBlock = computed(() => {
      // Если это не WebApp и нет переопределения и браузерный доступ запрещен - показываем заглушку
      return !isWebApp.value && !browserOverride.value && !browserAccessEnabled.value
    })

    // Определение WebApp
    const detectWebApp = () => {
      isWebApp.value = !!(window.Telegram && window.Telegram.WebApp)
    }

    // Загрузка настроек регистрации
    const loadRegistrationSettings = async () => {
      try {
        const response = await api.get('/api/registration-settings')
        browserAccessEnabled.value = response.data.browser_access_enabled || false
        console.log('Настройки загружены:', response.data)
      } catch (error) {
        console.error('Ошибка загрузки настроек:', error)
        // По умолчанию запрещаем доступ через браузер
        browserAccessEnabled.value = false
      }
    }

    // Принудительное обновление настроек
    const refreshSettings = async () => {
      await loadRegistrationSettings()
    }

    // Периодическое обновление настроек (каждые 30 секунд)
    let settingsInterval = null
    const startSettingsPolling = () => {
      settingsInterval = setInterval(async () => {
        await loadRegistrationSettings()
      }, 30000) // 30 секунд
    }

    const stopSettingsPolling = () => {
      if (settingsInterval) {
        clearInterval(settingsInterval)
        settingsInterval = null
      }
    }

    // Проверка на админа (по URL параметру или localStorage)
    const checkAdminStatus = () => {
      const urlParams = new URLSearchParams(window.location.search)
      const adminKey = urlParams.get('admin') || localStorage.getItem('admin_override')
      
      if (adminKey === 'true' || adminKey === 'admin123') {
        isAdmin.value = true
        localStorage.setItem('admin_override', 'true')
      }
    }

    // Включение регистрации (для админов)
    const enableRegistration = () => {
      browserOverride.value = true
      localStorage.setItem('browser_override', 'true')
    }

    // Проверка сохраненного состояния
    const checkSavedState = () => {
      const savedOverride = localStorage.getItem('browser_override')
      if (savedOverride === 'true') {
        browserOverride.value = true
      }
    }

    onMounted(async () => {
      detectWebApp()
      checkAdminStatus()
      checkSavedState()
      await loadRegistrationSettings()
      
      // Запускаем периодическое обновление настроек
      startSettingsPolling()
      
      // Инициализация Telegram Web App
      if (window.Telegram && window.Telegram.WebApp) {
        const tg = window.Telegram.WebApp
        tg.ready()
        tg.expand()
        
        // Получаем данные пользователя
        if (tg.initDataUnsafe && tg.initDataUnsafe.user) {
          telegramUser.value = tg.initDataUnsafe.user
        }
      }
    })

    onUnmounted(() => {
      stopSettingsPolling()
    })

    return {
      telegramUser,
      showBrowserBlock,
      isAdmin,
      enableRegistration,
      refreshSettings
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