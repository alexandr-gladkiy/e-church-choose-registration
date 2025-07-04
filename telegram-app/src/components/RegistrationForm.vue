<template>
  <div class="form-container">
    <!-- Информация о доступных местах -->
    <div v-if="registrationInfo && registrationInfo.max_participants" class="registration-info">
      <div class="info-card">
        <div class="stats-compact">
          <div class="stat-main">
            <span class="stat-icon">🎯</span>
            <span class="stat-label">Доступно мест:</span>
            <span class="stat-value" :class="{ 
              'warning': registrationInfo.available_spots <= 5 && registrationInfo.available_spots > 0, 
              'danger': registrationInfo.available_spots === 0 
            }">
              {{ registrationInfo.available_spots }}
            </span>
          </div>
          <div class="stat-secondary">
            <span class="stat-small">из {{ registrationInfo.max_participants }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Сообщение о закрытой регистрации -->
    <div v-if="registrationInfo && registrationInfo.is_full" class="registration-closed">
      <div class="closed-message">
        <h3>🚫 Регистрация закрыта</h3>
        <p>Достигнут лимит участников ({{ registrationInfo.max_participants }}).</p>
        <p>Если у вас есть вопросы, обратитесь к организаторам.</p>
      </div>
    </div>

    <!-- Сообщение о существующем пользователе -->
    <RegisteredUser
      v-if="existingUser"
      :user="existingUser"
      :is-loading="isLoading"
      @cancel-registration="handleCancelRegistration"
    />
    <div v-else-if="!registrationInfo?.is_full">
      <div v-if="existingUserMessage" class="existing-user-message">
        <div class="message-content">
          <h3>Информация о регистрации</h3>
          <p>{{ existingUserMessage }}</p>
          <div v-if="existingUser" class="existing-user-details">
            <p><strong>Имя:</strong> {{ existingUser.full_name }}</p>
            <p v-if="existingUser.phone"><strong>Телефон:</strong> {{ existingUser.phone }}</p>
            <p v-if="existingUser.telegram_username"><strong>Telegram:</strong> @{{ existingUser.telegram_username }}</p>
            <p><strong>Дата регистрации:</strong> {{ formatDate(existingUser.registration_date) }}</p>
          </div>
        </div>
      </div>
      
      <form @submit.prevent="showConfirmation" class="registration-form">
        <div class="form-group">
          <label for="fullName">Ваши Ф.И.О. *</label>
          <input
            type="text" 
            id="fullName"
            v-model="form.fullName"
            :class="{ 'error': errors.fullName }"
            required
          >
          <div v-if="errors.fullName" class="error-message">{{ errors.fullName }}</div>
        </div>

        <div class="form-group">
          <label for="city">Город *</label>
          <div class="city-input-container">
            <input
              type="text" 
              id="city"
              v-model="form.city"
              :class="{ 'error': errors.city }"
              placeholder="Начните вводить название города"
              @input="filterCities"
              @focus="showCityDropdown = true"
              required
            >
            <div v-if="showCityDropdown && filteredCities.length > 0" class="city-dropdown">
              <div 
                v-for="city in filteredCities"
                :key="city"
                class="city-option"
                @click="selectCity(city)"
              >
                {{ city }}
              </div>
            </div>
          </div>
          <div v-if="errors.city" class="error-message">{{ errors.city }}</div>
        </div>

        <div class="form-group">
          <label for="churchName">Название Церкви *</label>
          <input
            type="text" 
            id="churchName"
            v-model="form.churchName"
            :class="{ 'error': errors.churchName }"
            required
          >
          <div v-if="errors.churchName" class="error-message">{{ errors.churchName }}</div>
        </div>

        <div class="form-group">
          <label for="phone">Номер телефона для связи</label>
          <input
            type="tel"
            id="phone"
            v-model="form.phone"
            :class="{ 'error': errors.phone }"
            placeholder="+7 (999) 123-45-67"
            pattern="[0-9+\-\(\)\s]+"
            inputmode="numeric"
            @input="handlePhoneInput"
          >
          <div v-if="errors.phone" class="error-message">{{ errors.phone }}</div>
        </div>

        <div class="form-group">
          <label for="comments">Дополнительные комментарии</label>
          <textarea
            id="comments"
            v-model="form.comments"
            rows="4" 
            placeholder="Расскажите о себе или укажите особые пожелания..."
          ></textarea>
        </div>
        
        <div class="form-group checkbox-group">
          <label class="checkbox-label">
            <input 
              type="checkbox" 
              id="needAccommodation" 
              v-model="form.needAccommodation"
            >
            <span class="checkmark"></span>
            Нуждаюсь в расселении
          </label>
        </div>
        
        <div class="form-group checkbox-group">
          <label class="checkbox-label">
            <input 
              type="checkbox"
              id="terms" 
              v-model="form.terms"
              :class="{ 'error': errors.terms }"
              required
            >
            <span class="checkmark"></span>
            Я даю согласие на обработку  <a href="#" class="terms-link">персональных данных</a> *
          </label>
          <div v-if="errors.terms" class="error-message">{{ errors.terms }}</div>
        </div>

        <div class="form-group checkbox-group">
          <label class="checkbox-label">
            <input 
              type="checkbox"
              id="terms" 
              v-model="form.terms"
              :class="{ 'error': errors.terms }"
              required
            >
            <span class="checkmark"></span>
            Я согласен с <a href="#" class="terms-link">условиями участия</a> *
          </label>
          <div v-if="errors.terms" class="error-message">{{ errors.terms }}</div>
        </div>

        <button type="submit" class="submit-btn" :disabled="isLoading || !form.terms">
          <span v-if="!isLoading" class="btn-text">Зарегистрироваться</span>
          <span v-else class="btn-loading">
            <div class="spinner"></div>
            Отправка...
          </span>
        </button>
      </form>

      <!-- Диалог подтверждения -->
      <ConfirmDialog
        :show="showConfirmDialog"
        :registration-data="form"
        :is-loading="isLoading"
        @confirm="submitForm"
        @cancel="hideConfirmation"
      />
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import api from '../api'
import ConfirmDialog from './ConfirmDialog.vue'
import RegisteredUser from './RegisteredUser.vue'

export default {
  name: 'RegistrationForm',
  components: {
    ConfirmDialog,
    RegisteredUser
  },
  props: {
    telegramUser: {
      type: Object,
      default: null
    }
  },
  emits: ['registration-success'],
  setup(props, { emit }) {
    const isLoading = ref(false)
    const showCityDropdown = ref(false)
    const showConfirmDialog = ref(false)
    const existingUserMessage = ref('')
    const existingUser = ref(null)
    const cities = ref([])
    const filteredCities = ref([])
    const registrationInfo = ref(null)
    
    // Определяем, открыто ли приложение в WebApp
    const isWebApp = ref(false)
    
    const form = reactive({
      fullName: '',
      city: '',
      churchName: '',
      phone: '',
      comments: '',
      needAccommodation: false,
      terms: false
    })

    const errors = reactive({
      fullName: '',
      city: '',
      churchName: '',
      terms: ''
    })
    
    // Форматирование даты
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
    
    // Определение WebApp
    const detectWebApp = () => {
      isWebApp.value = !!(window.Telegram && window.Telegram.WebApp)
    }
    
    // Загрузка информации о регистрации
    const loadRegistrationInfo = async () => {
      try {
        const response = await api.get('/api/registration-settings')
        registrationInfo.value = response.data
      } catch (error) {
        console.error('Ошибка загрузки информации о регистрации:', error)
      }
    }
    
    // Загрузка городов из JSON файла
    const loadCities = async () => {
      try {
        const response = await fetch('/cities.json')
        cities.value = await response.json()
        filterCities() // Показываем первые 10 городов при загрузке
      } catch (error) {
        console.error('Ошибка загрузки городов:', error)
        // Fallback cities
        cities.value = [
          'Москва', 'Санкт-Петербург', 'Новосибирск', 'Екатеринбург', 'Казань',
          'Нижний Новгород', 'Челябинск', 'Самара', 'Уфа', 'Ростов-на-Дону'
        ]
        filterCities()
      }
    }
    
    // Фильтрация городов
    const filterCities = () => {
      if (!form.city) {
        filteredCities.value = cities.value.slice(0, 10)
      } else {
        filteredCities.value = cities.value
          .filter(city => city.toLowerCase().includes(form.city.toLowerCase()))
          .slice(0, 10)
      }
    }

    // Выбор города
    const selectCity = (city) => {
      form.city = city
      showCityDropdown.value = false
    }

    // Форматирование номера телефона
    const formatPhone = (value) => {
      // Убираем все символы кроме цифр и +
      let cleaned = value.replace(/[^\d+]/g, '')
      
      // Если начинается с 8, заменяем на +7
      if (cleaned.startsWith('8')) {
        cleaned = '+7' + cleaned.substring(1)
      }
      
      // Если начинается с 7 без +, добавляем +
      if (cleaned.startsWith('7') && !cleaned.startsWith('+7')) {
        cleaned = '+' + cleaned
      }
      
      // Если не начинается с +, добавляем +
      if (!cleaned.startsWith('+') && cleaned.length > 0) {
        cleaned = '+' + cleaned
      }
      
      // Форматируем номер в виде +7 (999) 123-45-67
      if (cleaned.startsWith('+7') && cleaned.length >= 12) {
        const match = cleaned.match(/^\+7(\d{3})(\d{3})(\d{2})(\d{2})$/)
        if (match) {
          return `+7 (${match[1]}) ${match[2]}-${match[3]}-${match[4]}`
        }
      }
      
      return cleaned
    }

    const validatePhone = () => {
      // Очищаем ошибку телефона
      errors.phone = ''
      
      // Если поле пустое - не валидируем (поле необязательное)
      if (!form.phone.trim()) {
        return true
      }
      
      // Убираем все пробелы и символы форматирования
      const cleanPhone = form.phone.replace(/[\s\-\(\)]/g, '')
      
      // Проверяем, что остались только цифры и +
      if (!/^\+?[0-9]+$/.test(cleanPhone)) {
        errors.phone = 'Номер телефона может содержать только цифры, пробелы, скобки и знак +'
        return false
      }
      
      // Проверяем длину (минимум 10 цифр, максимум 15)
      const digitsOnly = cleanPhone.replace(/\+/, '')
      if (digitsOnly.length < 10) {
        errors.phone = 'Номер телефона должен содержать минимум 10 цифр'
        return false
      }
      
      if (digitsOnly.length > 15) {
        errors.phone = 'Номер телефона слишком длинный'
        return false
      }
      
      // Проверяем, что номер начинается с +7 или 7 или 8 (для России)
      if (!/^(\+?7|8)/.test(cleanPhone)) {
        errors.phone = 'Номер должен начинаться с +7, 7 или 8'
        return false
      }
      
      return true
    }

    // Обработчик изменения номера телефона
    const handlePhoneInput = (event) => {
      const formatted = formatPhone(event.target.value)
      form.phone = formatted
      validatePhone()
    }

    // Валидация формы
    const validateForm = () => {
      let isValid = true
      
      // Очищаем ошибки и сообщения
      Object.keys(errors).forEach(key => errors[key] = '')
      existingUserMessage.value = ''
      existingUser.value = null
      
      // Проверяем, открыта ли регистрация
      if (registrationInfo.value && !registrationInfo.value.is_open) {
        alert('Регистрация закрыта')
        return false
      }
      
      // Проверяем, не достигнут ли лимит
      if (registrationInfo.value && registrationInfo.value.is_full) {
        alert('Достигнут лимит участников')
        return false
      }
      
      // Валидация имени
      if (!form.fullName.trim()) {
        errors.fullName = 'Поле "Полное имя" обязательно для заполнения'
        isValid = false
      } else if (form.fullName.trim().length < 2) {
        errors.fullName = 'Имя должно содержать минимум 2 символа'
        isValid = false
      }
      
      // Валидация города
      if (!form.city.trim()) {
        errors.city = 'Поле "Город" обязательно для заполнения'
        isValid = false
      } else if (form.city.trim().length < 2) {
        errors.city = 'Название города должно содержать минимум 2 символа'
        isValid = false
      }

      // Валидация церкви
      if (!form.churchName.trim()) {
        errors.churchName = 'Поле "Название Церкви" обязательно для заполнения'
        isValid = false
      } else if (form.churchName.trim().length < 3) {
        errors.churchName = 'Название церкви должно содержать минимум 3 символа'
        isValid = false
      }
      
      // Валидация телефона
      if (!validatePhone()) {
        isValid = false
      }
      
      // Валидация согласия с условиями
      if (!form.terms) {
        errors.terms = 'Необходимо согласие с условиями участия'
        isValid = false
      }

      return isValid
    }

    // Показать диалог подтверждения
    const showConfirmation = () => {
      if (validateForm()) {
        showConfirmDialog.value = true
      }
    }

    // Скрыть диалог подтверждения
    const hideConfirmation = () => {
      showConfirmDialog.value = false
    }

    // Отправка формы
    const submitForm = async () => {
      isLoading.value = true
      try {
        // Подготавливаем данные для отправки
        const submitData = {
          full_name: form.fullName,
          city: form.city,
          church_name: form.churchName,
          comments: form.comments,
          need_accommodation: form.needAccommodation,
          phone: form.phone
        }
        
        // Добавляем Telegram данные из props
        if (props.telegramUser) {
          submitData.telegram_username = props.telegramUser.username
          submitData.telegram_id = props.telegramUser.id
        }
        
        console.log('Отправляемые данные:', submitData)
        
        // Отправка данных на backend-api
        const response = await api.post('/api/users', submitData)
        
        // Успешная регистрация
        const registeredUser = response.data.user || response.data
        existingUser.value = registeredUser
        existingUserMessage.value = ''
        showConfirmDialog.value = false
        
        // Показываем сообщение о повторной активации, если это было
        if (response.data.reactivated) {
          existingUserMessage.value = 'Ваша регистрация была успешно восстановлена!'
        }
        
        // Обновляем информацию о регистрации
        await loadRegistrationInfo()
      } catch (error) {
        console.error('Ошибка при отправке формы:', error)
        if (error.response && error.response.status === 400) {
          existingUserMessage.value = error.response.data.error || error.response.data.message
          existingUser.value = error.response.data.existingUser
          showConfirmDialog.value = false
        } else {
          alert('Произошла ошибка при отправке формы. Попробуйте еще раз.')
        }
      } finally {
        isLoading.value = false
      }
    }
    
    // Закрытие выпадающего списка при клике вне его
    const handleClickOutside = (event) => {
      if (!event.target.closest('.city-input-container')) {
        showCityDropdown.value = false
      }
    }

    const handleCancelRegistration = async () => {
      const userId = existingUser.value?.id
      if (!userId) {
        alert('Нет данных для отмены регистрации.');
        return
      }
      isLoading.value = true
      try {
        await api.post(`/api/users/${userId}/cancel`)
        existingUser.value = null
        existingUserMessage.value = 'Ваша регистрация была отменена. Вы можете зарегистрироваться повторно, заполнив форму ниже.'
        // Обновляем информацию о регистрации
        await loadRegistrationInfo()
      } catch (error) {
        alert('Ошибка при отмене регистрации. Попробуйте еще раз.')
      } finally {
        isLoading.value = false
      }
    }

    onMounted(async () => {
      document.addEventListener('click', handleClickOutside)
      loadCities()
      detectWebApp()
      loadRegistrationInfo()
      
      // Автозаполнение данных из Telegram
      try {
        const telegramId = props.telegramUser?.id;
        let userFound = false;
        if (telegramId) {
          const resp = await api.get(`/api/users?telegramId=${telegramId}`)
          console.log('Ответ API для автозаполнения:', resp.data)

          let u = null;
          if (Array.isArray(resp.data)) {
            u = resp.data.find(user => String(user.telegram_id) === String(telegramId));
          }

          if (u && !u.cancelled_at) {
            // Пользователь найден и активен — показываем блок
            existingUser.value = u
            existingUserMessage.value = ''
            userFound = true
            return // Не перезаписываем форму, не сбрасываем existingUser
          } else if (u && u.cancelled_at) {
            existingUser.value = null
            existingUserMessage.value = 'Ваша предыдущая регистрация была отменена. Вы можете зарегистрироваться повторно, заполнив форму ниже.'
            userFound = true
          }
        }
        // Если пользователя нет в базе — автозаполняем из Telegram
        if (!userFound && props.telegramUser) {
          if (props.telegramUser.first_name) {
            form.fullName = props.telegramUser.first_name
            if (props.telegramUser.last_name) {
              form.fullName += ' ' + props.telegramUser.last_name
            }
          }
          if (isWebApp.value && window.Telegram?.WebApp?.initDataUnsafe?.user?.phone_number) {
            form.phone = window.Telegram.WebApp.initDataUnsafe.user.phone_number
          }
          existingUser.value = null
          existingUserMessage.value = ''
        }
      } catch (e) {
        console.error('Ошибка при загрузке данных пользователя:', e)
        // При ошибке API — автозаполняем из Telegram
        if (props.telegramUser && props.telegramUser.first_name) {
          form.fullName = props.telegramUser.first_name
          if (props.telegramUser.last_name) {
            form.fullName += ' ' + props.telegramUser.last_name
          }
        }
        if (isWebApp.value && window.Telegram?.WebApp?.initDataUnsafe?.user?.phone_number) {
          form.phone = window.Telegram.WebApp.initDataUnsafe.user.phone_number
        }
        existingUser.value = null
        existingUserMessage.value = ''
      }
    })
    
    onUnmounted(() => {
      document.removeEventListener('click', handleClickOutside)
    })

    return {
      form,
      errors,
      isLoading,
      showCityDropdown,
      showConfirmDialog,
      filteredCities,
      existingUserMessage,
      existingUser,
      registrationInfo,
      isWebApp,
      formatDate,
      filterCities,
      selectCity,
      showConfirmation,
      hideConfirmation,
      submitForm,
      handleCancelRegistration,
      handlePhoneInput
    }
  }
}
</script>

<style scoped>
.form-container {
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
}

.existing-user-message {
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a52 100%);
  color: white;
  padding: 20px;
  border-radius: 12px;
  margin-bottom: 20px;
  box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
}

.existing-user-message h3 {
  margin: 0 0 10px 0;
  font-size: 1.2em;
}

.existing-user-message p {
  margin: 0 0 15px 0;
  opacity: 0.9;
}

.existing-user-details {
  background: rgba(255, 255, 255, 0.1);
  padding: 15px;
  border-radius: 8px;
  margin-top: 10px;
}

.existing-user-details p {
  margin: 5px 0;
  font-size: 0.9em;
}

.registration-form {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  font-weight: 500;
  color: #333;
  font-size: 0.95rem;
}

.form-group input,
.form-group select,
.form-group textarea {
  padding: 16px;
  border: 2px solid rgba(225, 229, 233, 0.8);
  border-radius: 12px;
  font-size: 1rem;
  font-family: inherit;
  transition: all 0.3s ease;
  background: rgba(250, 251, 252, 0.9);
  backdrop-filter: blur(10px);
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #667eea;
  background: rgba(255, 255, 255, 0.95);
  box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
}

.form-group input.error,
.form-group select.error,
.form-group textarea.error {
  border-color: #e74c3c;
  background: rgba(253, 242, 242, 0.9);
}

.form-group input.error:focus,
.form-group select.error:focus,
.form-group textarea.error:focus {
  box-shadow: 0 0 0 4px rgba(231, 76, 60, 0.1);
}

.form-group input::placeholder,
.form-group textarea::placeholder {
  color: #999;
  opacity: 0.7;
}

.error-message {
  color: #e74c3c;
  font-size: 0.85rem;
  margin-top: 4px;
  font-weight: 500;
}

.city-input-container {
  position: relative;
}

.city-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border: 2px solid rgba(225, 229, 233, 0.8);
  border-top: none;
  border-radius: 0 0 12px 12px;
  max-height: 200px;
  overflow-y: auto;
  z-index: 1000;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.city-option {
  padding: 12px 16px;
  cursor: pointer;
  transition: background-color 0.2s ease;
  border-bottom: 1px solid rgba(240, 240, 240, 0.5);
}

.city-option:hover {
  background-color: rgba(248, 249, 250, 0.8);
}

.city-option:last-child {
  border-bottom: none;
}

.checkbox-group {
  flex-direction: row;
  align-items: center;
  gap: 12px;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  font-weight: 400;
  color: #555;
  font-size: 0.95rem;
  position: relative;
}

.checkbox-label input[type="checkbox"] {
  width: 20px;
  height: 20px;
  cursor: pointer;
  opacity: 0;
  position: absolute;
}

.checkmark {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(225, 229, 233, 0.8);
  border-radius: 6px;
  background: rgba(250, 251, 252, 0.9);
  position: relative;
  transition: all 0.3s ease;
}

.checkbox-label input[type="checkbox"]:checked + .checkmark {
  background: #667eea;
  border-color: #667eea;
}

.checkbox-label input[type="checkbox"]:checked + .checkmark::after {
  content: '✓';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: white;
  font-size: 12px;
  font-weight: bold;
}

.checkbox-label input[type="checkbox"]:focus + .checkmark {
  box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
}

.terms-link {
  color: #667eea;
  text-decoration: none;
  font-weight: 600;
}

.terms-link:hover {
  text-decoration: underline;
}

.submit-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 18px 32px;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

.submit-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 12px 35px rgba(102, 126, 234, 0.4);
}

.submit-btn:active {
  transform: translateY(0);
}

.submit-btn:disabled {
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
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Адаптивность для мобильных устройств */
@media (max-width: 768px) {
  .form-container {
    padding: 20px;
  }
}

/* Стили для Telegram полей */
.telegram-fields {
  background: rgba(102, 126, 234, 0.05);
  border: 2px solid rgba(102, 126, 234, 0.1);
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
}

.telegram-fields::before {
  content: '🌐 Режим браузера';
  display: block;
  font-size: 0.9rem;
  font-weight: 600;
  color: #667eea;
  margin-bottom: 15px;
  text-align: center;
}

/* Стили для информации о Telegram пользователе */
.telegram-info {
  margin-bottom: 20px;
}

.info-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

.info-card h4 {
  margin: 0 0 15px 0;
  font-size: 1.1rem;
  display: flex;
  align-items: center;
  gap: 8px;
}

.info-card p {
  margin: 8px 0;
  font-size: 0.95rem;
  opacity: 0.95;
}

.info-card strong {
  font-weight: 600;
  opacity: 1;
}

/* Стили для информации о регистрации */
.registration-info {
  margin-bottom: 20px;
}

.registration-info .info-card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.stats-compact {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 15px;
}

.stat-main {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: 1;
}

.stat-icon {
  font-size: 1.2rem;
}

.stat-label {
  font-size: 0.9rem;
  color: #666;
  font-weight: 500;
}

.stat-value {
  font-size: 1.3rem;
  font-weight: 700;
  color: #333;
  padding: 4px 8px;
  border-radius: 6px;
  background: rgba(40, 167, 69, 0.1);
  color: #28a745;
}

.stat-value.warning {
  background: rgba(255, 193, 7, 0.1);
  color: #ffc107;
}

.stat-value.danger {
  background: rgba(220, 53, 69, 0.1);
  color: #dc3545;
}

.stat-secondary {
  text-align: right;
}

.stat-small {
  font-size: 0.8rem;
  color: #999;
  font-weight: 400;
}

/* Стили для закрытой регистрации */
.registration-closed {
  margin-bottom: 20px;
}

.closed-message {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
  color: white;
  padding: 30px;
  border-radius: 12px;
  text-align: center;
  box-shadow: 0 8px 25px rgba(220, 53, 69, 0.3);
}

.closed-message h3 {
  margin: 0 0 15px 0;
  font-size: 1.3rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.closed-message p {
  margin: 8px 0;
  font-size: 1rem;
  opacity: 0.95;
}
</style> 