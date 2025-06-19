<template>
  <form class="card p-4 shadow-sm mx-auto" style="max-width:400px;" @submit.prevent="onChangePassword">
    <h3 class="h5 text-center mb-4">Сменить пароль</h3>
    <div class="mb-3">
      <label class="form-label">Старый пароль:<span class="text-danger">*</span>
        <input v-model="oldPassword" type="password" class="form-control" required />
      </label>
    </div>
    <div class="mb-3">
      <label class="form-label">Новый пароль:<span class="text-danger">*</span>
        <input v-model="newPassword" type="password" class="form-control" required />
      </label>
    </div>
    <button class="btn btn-warning w-100 d-flex align-items-center justify-content-center" :disabled="loading">
      <span v-if="loading" class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
      Сменить
    </button>
    <div v-if="error" class="alert alert-danger mt-3 text-center">{{ error }}</div>
    <div v-if="success" class="alert alert-success mt-3 text-center">{{ success }}</div>
  </form>
</template>

<script setup>
import { ref, watch } from 'vue'
const emit = defineEmits(['change-password'])
const oldPassword = ref('')
const newPassword = ref('')
const error = ref('')
const success = ref('')
const loading = ref(false)

watch(success, (val) => {
  if (val) {
    oldPassword.value = ''
    newPassword.value = ''
    setTimeout(() => {
      success.value = ''
      emit('close')
    }, 2000)
  }
})

async function onChangePassword() {
  error.value = ''
  success.value = ''
  loading.value = true
  if (!oldPassword.value || !newPassword.value) {
    error.value = 'Заполните оба поля'
    loading.value = false
    return
  }
  await emit('change-password', {
    oldPassword: oldPassword.value,
    newPassword: newPassword.value,
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
      loading.value = false
    }
  })
}
</script>

<style scoped>
.change-password-form {
  padding: 40px;
  max-width: 400px;
  margin: 0 auto 30px auto;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 24px rgba(102, 126, 234, 0.08);
}
.change-password-form h3 {
  text-align: center;
  margin-bottom: 20px;
}
.form-group {
  margin-bottom: 20px;
}
.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #2c3e50;
}
.form-group input[type="password"] {
  width: 100%;
  padding: 12px 15px;
  border: 2px solid #e1e8ed;
  border-radius: 8px;
  font-size: 16px;
  transition: border-color 0.3s ease;
}
.form-group input:focus {
  outline: none;
  border-color: #667eea;
}
.btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px 30px;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s ease;
  width: 100%;
}
.btn:hover {
  transform: translateY(-2px);
}
.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}
.error {
  background: #e74c3c;
  color: white;
  padding: 15px;
  border-radius: 8px;
  margin-top: 20px;
  text-align: center;
}
.success {
  background: #27ae60;
  color: white;
  padding: 15px;
  border-radius: 8px;
  margin-top: 20px;
  text-align: center;
}
</style> 