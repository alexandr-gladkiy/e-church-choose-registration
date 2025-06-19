<template>
  <div class="container">
    <div class="header">
      <h1>Админ панель</h1>
      <p>Управление регистрациями на мероприятие</p>
      <button v-if="isAuth" class="logout-btn" @click="logout">Выйти</button>
    </div>
    <Message :message="message.text" :type="message.type" v-if="message.text" />
    <LoginForm v-if="!isAuth" @login="handleLogin" />
    <div v-else>
      <StatsGrid :stats="stats" />
      <div class="actions" style="display:flex;gap:15px;margin-bottom:30px;flex-wrap:wrap;">
        <button class="btn btn-success" @click="exportCSVFile">Экспорт в CSV</button>
        <button class="btn btn-secondary" @click="refreshData">Обновить данные</button>
        <button class="btn btn-secondary" @click="openChangePassword">Изменить пароль</button>
      </div>
      <ChangePasswordForm v-if="showChangePassword" @change-password="handleChangePassword" />
      <AddUserForm @add="handleAddUser" />
      <RegistrationsTable :users="users" @cancel="handleCancel" />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import LoginForm from './components/LoginForm.vue'
import StatsGrid from './components/StatsGrid.vue'
import RegistrationsTable from './components/RegistrationsTable.vue'
import AddUserForm from './components/AddUserForm.vue'
import Message from './components/Message.vue'
import ChangePasswordForm from './components/ChangePasswordForm.vue'
import { login, fetchUsers, addUser, cancelRegistration, exportCSV, changePassword } from './api.js'

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

function showMessage(text, type = 'success') {
  message.value = { text, type }
  setTimeout(() => { message.value.text = '' }, 4000)
}

async function handleLogin({ username, password, setError }) {
  const res = await login(username, password)
  if (res.success) {
    isAuth.value = true
    showMessage('Вход выполнен', 'success')
    await loadData()
  } else {
    setError(res.error || 'Ошибка авторизации')
  }
}

async function loadData() {
  const data = await fetchUsers()
  users.value = Array.isArray(data) ? data : []
  stats.value.totalRegistrations = users.value.length
  stats.value.webRegistrations = users.value.filter(u => !u.telegram_username).length
  stats.value.telegramRegistrations = users.value.filter(u => u.telegram_username).length
  stats.value.withAccommodation = users.value.filter(u => u.need_accommodation).length
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
  const blob = await exportCSV()
  const url = window.URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = 'registrations.csv'
  a.click()
  window.URL.revokeObjectURL(url)
}

function logout() {
  isAuth.value = false
  users.value = []
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
