<template>
  <div class="stats-grid">
    <div class="stat-card">
      <h3>{{ stats.totalRegistrations }}</h3>
      <p>Всего регистраций</p>
    </div>
    <div class="stat-card">
      <h3>{{ stats.webRegistrations }}</h3>
      <p>Web регистраций</p>
    </div>
    <div class="stat-card">
      <h3>{{ stats.telegramRegistrations }}</h3>
      <p>Telegram регистраций</p>
    </div>
    <div class="stat-card">
      <h3>{{ stats.withAccommodation }}</h3>
      <p>Нужно жилье</p>
    </div>
    <div class="stat-card settings-card">
      <h4>Настройки регистрации</h4>
      <div v-if="settings">
        <div>Статус: <b :style="{color: settings.is_open ? 'green' : 'red'}">{{ settings.is_open ? 'Открыта' : 'Закрыта' }}</b></div>
        <div>Начало: {{ settings.registration_start ? (new Date(settings.registration_start)).toLocaleString() : '—' }}</div>
        <div>Дедлайн: {{ settings.registration_deadline ? (new Date(settings.registration_deadline)).toLocaleString() : '—' }}</div>
        <button class="btn" @click="editMode = !editMode">{{ editMode ? 'Отмена' : 'Изменить' }}</button>
        <form v-if="editMode" @submit.prevent="saveSettings" style="margin-top:10px;">
          <label>Статус:
            <select v-model="form.is_open">
              <option :value="true">Открыта</option>
              <option :value="false">Закрыта</option>
            </select>
          </label>
          <label>Начало:
            <input type="datetime-local" v-model="form.registration_start" />
          </label>
          <label>Дедлайн:
            <input type="datetime-local" v-model="form.registration_deadline" />
          </label>
          <button class="btn" type="submit">Сохранить</button>
        </form>
        <div v-if="msg" :class="msgType">{{ msg }}</div>
      </div>
      <div v-else>Загрузка настроек...</div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { fetchRegistrationSettings, updateRegistrationSettings } from '../api.js'
const props = defineProps({
  stats: {
    type: Object,
    required: true
  }
})
const settings = ref(null)
const editMode = ref(false)
const form = ref({ is_open: true, registration_start: '', registration_deadline: '' })
const msg = ref('')
const msgType = ref('success')

async function loadSettings() {
  try {
    const data = await fetchRegistrationSettings()
    settings.value = data
    form.value = {
      is_open: !!data.is_open,
      registration_start: data.registration_start ? data.registration_start.slice(0, 16) : '',
      registration_deadline: data.registration_deadline ? data.registration_deadline.slice(0, 16) : ''
    }
  } catch (e) {
    msg.value = e.error || 'Ошибка загрузки настроек'
    msgType.value = 'error'
  }
}
onMounted(loadSettings)

async function saveSettings() {
  msg.value = ''
  try {
    const payload = {
      is_open: form.value.is_open,
      registration_start: form.value.registration_start ? new Date(form.value.registration_start).toISOString() : null,
      registration_deadline: form.value.registration_deadline ? new Date(form.value.registration_deadline).toISOString() : null
    }
    const res = await updateRegistrationSettings(payload)
    if (res.success) {
      msg.value = 'Настройки сохранены'
      msgType.value = 'success'
      await loadSettings()
      editMode.value = false
    } else {
      msg.value = res.error || 'Ошибка сохранения'
      msgType.value = 'error'
    }
  } catch (e) {
    if (e.error && (e.error === 'Неверный токен' || e.error === 'Нет токена')) {
      localStorage.removeItem('token')
      window.location.reload()
    } else {
      msg.value = e.error || 'Ошибка сохранения'
      msgType.value = 'error'
    }
  }
}
</script>

<style scoped>
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}
.stat-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 25px;
  border-radius: 12px;
  text-align: center;
}
.settings-card {
  background: #fff;
  color: #222;
  box-shadow: 0 2px 8px rgba(102,126,234,0.08);
  min-width: 220px;
}
.settings-card h4 {
  margin-bottom: 10px;
}
.settings-card label {
  display: block;
  margin: 8px 0;
  color: #222;
}
.settings-card input, .settings-card select {
  width: 100%;
  margin-top: 4px;
  margin-bottom: 8px;
  padding: 6px 10px;
  border-radius: 6px;
  border: 1px solid #e1e8ed;
}
.settings-card .btn {
  margin-top: 8px;
  background: #667eea;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 8px 18px;
  cursor: pointer;
}
.success {
  background: #27ae60;
  color: white;
  padding: 8px;
  border-radius: 6px;
  margin-top: 10px;
  text-align: center;
}
.error {
  background: #e74c3c;
  color: white;
  padding: 8px;
  border-radius: 6px;
  margin-top: 10px;
  text-align: center;
}
@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
}
</style> 