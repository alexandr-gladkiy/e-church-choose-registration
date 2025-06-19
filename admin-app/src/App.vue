<template>
  <div class="container py-4 position-relative">
    <div v-if="loading" class="position-fixed top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center bg-white bg-opacity-75" style="z-index:1050">
      <div class="spinner-border text-primary" style="width:3rem;height:3rem;" role="status"></div>
    </div>
    <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
      <div>
        <h1 class="h3 mb-1">Админ панель</h1>
        <p class="text-muted mb-0">Управление регистрациями на мероприятие</p>
      </div>
      <button v-if="isAuth" class="btn btn-outline-danger" @click="logout">Выйти</button>
    </div>
    <Message :message="message.text" :type="message.type" v-if="message.text" />
    <div class="row justify-content-center">
      <div class="col-lg-10 col-md-12">
        <LoginForm v-if="!isAuth" @login="handleLogin" />
        <div v-else>
          <ul class="nav nav-tabs mb-4">
            <li class="nav-item">
              <button class="nav-link" :class="{active: tab==='users'}" @click="tab='users'">Пользователи</button>
            </li>
            <li class="nav-item">
              <button class="nav-link" :class="{active: tab==='stats'}" @click="tab='stats'">Статистика</button>
            </li>
            <li class="nav-item">
              <button class="nav-link" :class="{active: tab==='settings'}" @click="tab='settings'">Настройки</button>
            </li>
            <li class="nav-item">
              <button class="nav-link" :class="{active: tab==='password'}" @click="tab='password'">Смена пароля</button>
            </li>
          </ul>
          <div v-if="tab==='users'">
            <div class="d-flex flex-wrap gap-2 mb-3">
              <button class="btn btn-success" @click="exportCSVFile">
                <i class="bi bi-download"></i> Экспорт в CSV
              </button>
              <button class="btn btn-secondary" @click="refreshData">
                <i class="bi bi-arrow-clockwise"></i> Обновить данные
              </button>
            </div>
            <AddUserForm @add="handleAddUser" class="mb-4" />
            <RegistrationsTable :users="users" @cancel="handleCancel" />
          </div>
          <div v-else-if="tab==='stats'">
            <StatsGrid :stats="stats" class="mb-4" />
          </div>
          <div v-else-if="tab==='settings'">
            <RegistrationSettingsForm />
          </div>
          <div v-else-if="tab==='password'">
            <ChangePasswordForm @change-password="handleChangePassword" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
console.log('import.meta.env:', import.meta.env)
console.log('VITE_API_URL:', import.meta.env.VITE_API_URL)
import { ref, onMounted } from 'vue'
import LoginForm from './components/LoginForm.vue'
import StatsGrid from './components/StatsGrid.vue'
import RegistrationsTable from './components/RegistrationsTable.vue'
import AddUserForm from './components/AddUserForm.vue'
import Message from './components/Message.vue'
import ChangePasswordForm from './components/ChangePasswordForm.vue'
import RegistrationSettingsForm from './components/RegistrationSettingsForm.vue'
import { login, fetchUsers, addUser, cancelRegistration, exportCSV, changePassword, getCurrentAdmin } from './api.js'

const isAuth = ref(false)
const users = ref([])
const stats = ref({
  totalRegistrations: 0,
  webRegistrations: 0,
  telegramRegistrations: 0,
  withAccommodation: 0
})
const message = ref({ text: '', type: 'success' })
const showChangePassword = ref(false)
const loading = ref(false)
const tab = ref('users')

function showMessage(text, type = 'success') {
  message.value = { text, type }
  setTimeout(() => { message.value.text = '' }, 4000)
}

onMounted(async () => {
  // Проверяем токен при загрузке
  const token = localStorage.getItem('token');
  if (token) {
    try {
      loading.value = true
      await getCurrentAdmin();
      isAuth.value = true;
      await loadData();
    } catch (e) {
      localStorage.removeItem('token');
      isAuth.value = false;
    } finally {
      loading.value = false
    }
  }
});

async function handleLogin({ username, password, setError }) {
  console.log('Попытка входа:', { username, password })
  try {
    const res = await login(username, password)
    console.log('Ответ от сервера:', res)
    if (res.success && res.token) {
      localStorage.setItem('token', res.token)
      isAuth.value = true
      showMessage('Вход выполнен', 'success')
      await loadData()
    } else {
      setError(res.error || 'Ошибка авторизации')
    }
  } catch (e) {
    console.error('Ошибка при входе:', e)
    setError(e.error || 'Ошибка авторизации')
  }
}

async function loadData() {
  try {
    loading.value = true
    const data = await fetchUsers()
    users.value = Array.isArray(data) ? data : []
    stats.value.totalRegistrations = users.value.length
    stats.value.webRegistrations = users.value.filter(u => !u.telegram_username).length
    stats.value.telegramRegistrations = users.value.filter(u => u.telegram_username).length
    stats.value.withAccommodation = users.value.filter(u => u.need_accommodation).length
  } catch (e) {
    if (e.error && (e.error === 'Неверный токен' || e.error === 'Нет токена')) {
      logout()
      showMessage('Сессия истекла, войдите снова', 'error')
    } else {
      showMessage(e.error || 'Ошибка загрузки данных', 'error')
    }
  } finally {
    loading.value = false
  }
}

async function handleAddUser(payload) {
  const { setError, setSuccess, ...user } = payload
  const res = await addUser({
    full_name: user.fullName,
    email: user.email,
    phone: user.phone,
    city: user.city,
    church_name: user.churchName,
    need_accommodation: user.needAccommodation,
    comments: user.comments,
    telegram_id: user.telegramId,
    telegram_username: user.telegramUsername
  })
  if (res.success) {
    setSuccess('Участник добавлен')
    await loadData()
  } else {
    setError(res.error || 'Ошибка добавления')
  }
}

async function handleCancel(userId) {
  const res = await cancelRegistration(userId)
  if (res.success) {
    showMessage('Регистрация отменена', 'success')
    await loadData()
  } else {
    showMessage(res.error || 'Ошибка отмены', 'error')
  }
}

function refreshData() {
  loadData()
  showMessage('Данные обновлены')
}

async function exportCSVFile() {
  try {
    loading.value = true
    const blob = await exportCSV()
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = 'registrations.csv'
    a.click()
    window.URL.revokeObjectURL(url)
  } finally {
    loading.value = false
  }
}

function logout() {
  isAuth.value = false
  users.value = []
  localStorage.removeItem('token')
  showMessage('Выход выполнен', 'success')
}

function openChangePassword() {
  showChangePassword.value = true
}
function closeChangePassword() {
  showChangePassword.value = false
}
async function handleChangePassword({ oldPassword, newPassword, setError, setSuccess }) {
  const res = await changePassword(oldPassword, newPassword)
  if (res.success) {
    setSuccess('Пароль успешно изменён')
    setTimeout(() => closeChangePassword(), 2000)
  } else {
    setError(res.error || 'Ошибка смены пароля')
  }
}
</script>

<style>
.actions .btn {
  margin-right: 10px;
}
.btn-secondary {
  background: linear-gradient(135deg, #95a5a6 0%, #7f8c8d 100%);
  color: white;
}
.btn-success {
  background: linear-gradient(135deg, #27ae60 0%, #2ecc71 100%);
  color: white;
}
</style>
