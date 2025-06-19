<template>
  <div class="card p-4 shadow-sm mb-4">
    <h5 class="mb-3">Настройки регистрации</h5>
    <div v-if="settings">
      <div class="mb-2">Статус: <b :class="settings.is_open ? 'text-success' : 'text-danger'">{{ settings.is_open ? 'Открыта' : 'Закрыта' }}</b></div>
      <div class="mb-2">Начало: {{ settings.registration_start ? (new Date(settings.registration_start)).toLocaleString() : '—' }}</div>
      <div class="mb-2">Дедлайн: {{ settings.registration_deadline ? (new Date(settings.registration_deadline)).toLocaleString() : '—' }}</div>
      <button class="btn btn-outline-primary btn-sm mb-3" @click="editMode = !editMode">{{ editMode ? 'Отмена' : 'Изменить' }}</button>
      <form v-if="editMode" @submit.prevent="saveSettings" class="row g-3">
        <div class="col-md-4">
          <label class="form-label">Статус:
            <select v-model="form.is_open" class="form-select">
              <option :value="true">Открыта</option>
              <option :value="false">Закрыта</option>
            </select>
          </label>
        </div>
        <div class="col-md-4">
          <label class="form-label">Начало:
            <input type="datetime-local" v-model="form.registration_start" class="form-control" />
          </label>
        </div>
        <div class="col-md-4">
          <label class="form-label">Дедлайн:
            <input type="datetime-local" v-model="form.registration_deadline" class="form-control" />
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
const form = ref({ is_open: true, registration_start: '', registration_deadline: '' })
const msg = ref('')
const msgType = ref('success')
const loading = ref(false)

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