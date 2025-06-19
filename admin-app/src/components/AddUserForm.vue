<template>
  <form class="card p-4 shadow-sm mx-auto" style="max-width:600px;" @submit.prevent="onAddUser">
    <h3 class="h5 text-center mb-4">Добавить участника</h3>
    <div class="row g-3">
      <div class="col-md-6">
        <label class="form-label">ФИО:<span class="text-danger">*</span>
          <input v-model="fullName" type="text" class="form-control" required />
        </label>
      </div>
      <div class="col-md-6">
        <label class="form-label">Email:
          <input v-model="email" type="email" class="form-control" />
        </label>
      </div>
      <div class="col-md-6">
        <label class="form-label">Телефон:
          <input v-model="phone" type="text" class="form-control" />
        </label>
      </div>
      <div class="col-md-6">
        <label class="form-label">Город:<span class="text-danger">*</span>
          <input v-model="city" type="text" class="form-control" required />
        </label>
      </div>
      <div class="col-md-6">
        <label class="form-label">Церковь:<span class="text-danger">*</span>
          <input v-model="churchName" type="text" class="form-control" required />
        </label>
      </div>
      <div class="col-md-6 d-flex align-items-center">
        <label class="form-label mb-0 me-2">Нужна гостиница:</label>
        <input v-model="needAccommodation" type="checkbox" class="form-check-input" />
      </div>
      <div class="col-md-12">
        <label class="form-label">Комментарий:
          <input v-model="comments" type="text" class="form-control" />
        </label>
      </div>
      <div class="col-md-6">
        <label class="form-label">Telegram ID:
          <input v-model="telegramId" type="text" class="form-control" />
        </label>
      </div>
      <div class="col-md-6">
        <label class="form-label">Telegram username:
          <input v-model="telegramUsername" type="text" class="form-control" />
        </label>
      </div>
    </div>
    <button class="btn btn-success w-100 mt-4 d-flex align-items-center justify-content-center" :disabled="loading">
      <span v-if="loading" class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
      Зарегистрировать
    </button>
    <div v-if="error" class="alert alert-danger mt-3 text-center">{{ error }}</div>
    <div v-if="success" class="alert alert-success mt-3 text-center">{{ success }}</div>
  </form>
</template>

<script setup>
import { ref } from 'vue'
const emit = defineEmits(['add'])
const fullName = ref('')
const email = ref('')
const phone = ref('')
const city = ref('')
const churchName = ref('')
const needAccommodation = ref(false)
const comments = ref('')
const telegramId = ref('')
const telegramUsername = ref('')
const error = ref('')
const success = ref('')
const loading = ref(false)

function resetFields() {
  fullName.value = ''
  email.value = ''
  phone.value = ''
  city.value = ''
  churchName.value = ''
  needAccommodation.value = false
  comments.value = ''
  telegramId.value = ''
  telegramUsername.value = ''
}

async function onAddUser() {
  error.value = ''
  success.value = ''
  loading.value = true
  if (!fullName.value || !city.value || !churchName.value) {
    error.value = 'Поля ФИО, Город и Церковь обязательны'
    loading.value = false
    return
  }
  await emit('add', {
    fullName: fullName.value,
    email: email.value,
    phone: phone.value,
    city: city.value,
    churchName: churchName.value,
    needAccommodation: needAccommodation.value,
    comments: comments.value,
    telegramId: telegramId.value,
    telegramUsername: telegramUsername.value,
    setError: (msg) => {
      if (msg === 'Неверный токен' || msg === 'Нет токена') {
        localStorage.removeItem('token')
        window.location.reload()
      } else {
        error.value = msg
      }
      loading.value = false
    },
    setSuccess: (msg) => {
      success.value = msg
      resetFields()
      loading.value = false
    }
  })
}
</script> 