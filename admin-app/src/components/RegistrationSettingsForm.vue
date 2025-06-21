<template>
  <div class="card p-4 shadow-sm mb-4">
    <h5 class="mb-3">Настройки регистрации</h5>
    <div v-if="settings">
      <!-- Статистика регистрации -->
      <div class="row mb-4">
        <div class="col-md-3">
          <div class="stat-card bg-primary text-white">
            <div class="stat-number">{{ settings.active_participants || 0 }}</div>
            <div class="stat-label">Зарегистрировано</div>
          </div>
        </div>
        <div class="col-md-3" v-if="settings.max_participants">
          <div class="stat-card bg-success text-white">
            <div class="stat-number">{{ settings.max_participants }}</div>
            <div class="stat-label">Максимум</div>
          </div>
        </div>
        <div class="col-md-3" v-if="settings.available_spots !== null">
          <div class="stat-card" :class="getAvailableSpotsClass()">
            <div class="stat-number">{{ settings.available_spots }}</div>
            <div class="stat-label">Доступно мест</div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="stat-card" :class="settings.is_open ? 'bg-success' : 'bg-danger'">
            <div class="stat-number">{{ settings.is_open ? 'Открыта' : 'Закрыта' }}</div>
            <div class="stat-label">Регистрация</div>
          </div>
        </div>
      </div>

      <div class="mb-2">Статус: <b :class="settings.is_open ? 'text-success' : 'text-danger'">{{ settings.is_open ? 'Открыта' : 'Закрыта' }}</b></div>
      <div class="mb-2">Начало: {{ settings.registration_start ? (new Date(settings.registration_start)).toLocaleString() : '—' }}</div>
      <div class="mb-2">Дедлайн: {{ settings.registration_deadline ? (new Date(settings.registration_deadline)).toLocaleString() : '—' }}</div>
      <div class="mb-2" v-if="settings.max_participants">Максимум участников: <b>{{ settings.max_participants }}</b></div>
      <div class="mb-2">Доступ через браузер: <b :class="settings.browser_access_enabled ? 'text-success' : 'text-danger'">{{ settings.browser_access_enabled ? 'Разрешен' : 'Запрещен' }}</b></div>
      
      <button class="btn btn-outline-primary btn-sm mb-3" @click="editMode = !editMode">{{ editMode ? 'Отмена' : 'Изменить' }}</button>
      
      <form v-if="editMode" @submit.prevent="saveSettings" class="row g-3">
        <div class="col-md-6">
          <label class="form-label">Статус регистрации:
            <select v-model="form.is_open" class="form-select">
              <option :value="true">Открыта</option>
              <option :value="false">Закрыта</option>
            </select>
          </label>
        </div>
        <div class="col-md-6">
          <label class="form-label">Доступ через браузер:
            <select v-model="form.browser_access_enabled" class="form-select">
              <option :value="true">Разрешен</option>
              <option :value="false">Запрещен</option>
            </select>
          </label>
        </div>
        <div class="col-md-4">
          <label class="form-label">Начало регистрации:
            <input type="datetime-local" v-model="form.registration_start" class="form-control" />
          </label>
        </div>
        <div class="col-md-4">
          <label class="form-label">Дедлайн регистрации:
            <input type="datetime-local" v-model="form.registration_deadline" class="form-control" />
          </label>
        </div>
        <div class="col-md-4">
          <label class="form-label">Максимум участников:
            <input type="number" v-model="form.max_participants" class="form-control" placeholder="Не ограничено" min="1" />
            <small class="form-text text-muted">Оставьте пустым для неограниченного количества</small>
          </label>
        </div>
        <div class="col-12">
          <button class="btn btn-primary" type="submit" :disabled="loading">
            <span v-if="loading" class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
            Сохранить
          </button>
        </div>
      </form>
      <div v-if="msg" :class="['mt-3', msgType==='success' ? 'alert alert-success' : 'alert alert-danger']">{{ msg }}</div>
    </div>
    <div v-else>Загрузка настроек...</div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { fetchRegistrationSettings, updateRegistrationSettings } from '../api.js'

const settings = ref(null)
const editMode = ref(false)
const form = ref({ 
  is_open: true, 
  registration_start: '', 
  registration_deadline: '',
  max_participants: null,
  browser_access_enabled: false
})
const msg = ref('')
const msgType = ref('success')
const loading = ref(false)

function getAvailableSpotsClass() {
  if (!settings.value || settings.value.available_spots === null) return 'bg-secondary text-white'
  if (settings.value.available_spots === 0) return 'bg-danger text-white'
  if (settings.value.available_spots <= 5) return 'bg-warning text-dark'
  return 'bg-success text-white'
}

async function loadSettings() {
  try {
    const data = await fetchRegistrationSettings()
    settings.value = data
    form.value = {
      is_open: !!data.is_open,
      registration_start: data.registration_start ? data.registration_start.slice(0, 16) : '',
      registration_deadline: data.registration_deadline ? data.registration_deadline.slice(0, 16) : '',
      max_participants: data.max_participants || null,
      browser_access_enabled: !!data.browser_access_enabled
    }
  } catch (e) {
    msg.value = e.error || 'Ошибка загрузки настроек'
    msgType.value = 'danger'
  }
}

onMounted(loadSettings)

async function saveSettings() {
  msg.value = ''
  loading.value = true
  try {
    const payload = {
      is_open: form.value.is_open,
      registration_start: form.value.registration_start ? new Date(form.value.registration_start).toISOString() : null,
      registration_deadline: form.value.registration_deadline ? new Date(form.value.registration_deadline).toISOString() : null,
      max_participants: form.value.max_participants ? parseInt(form.value.max_participants) : null,
      browser_access_enabled: form.value.browser_access_enabled
    }
    const res = await updateRegistrationSettings(payload)
    if (res.success) {
      msg.value = 'Настройки сохранены'
      msgType.value = 'success'
      await loadSettings()
      editMode.value = false
    } else {
      msg.value = res.error || 'Ошибка сохранения'
      msgType.value = 'danger'
    }
  } catch (e) {
    if (e.error && (e.error === 'Неверный токен' || e.error === 'Нет токена')) {
      localStorage.removeItem('token')
      window.location.reload()
    } else {
      msg.value = e.error || 'Ошибка сохранения'
      msgType.value = 'danger'
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.stat-card {
  padding: 1rem;
  border-radius: 0.5rem;
  text-align: center;
  margin-bottom: 1rem;
}

.stat-number {
  font-size: 1.5rem;
  font-weight: bold;
  margin-bottom: 0.25rem;
}

.stat-label {
  font-size: 0.875rem;
  opacity: 0.9;
}
</style> 