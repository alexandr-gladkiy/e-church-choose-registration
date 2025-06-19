<template>
  <form class="card p-4 shadow-sm mx-auto" style="max-width:400px;" @submit.prevent="onLogin">
    <h2 class="h4 text-center mb-4">Вход в систему</h2>
    <div class="mb-3">
      <label for="username" class="form-label">Логин:</label>
      <input v-model="username" type="text" id="username" class="form-control" placeholder="Введите логин" autocomplete="username" />
    </div>
    <div class="mb-3">
      <label for="password" class="form-label">Пароль:</label>
      <input v-model="password" type="password" id="password" class="form-control" placeholder="Введите пароль" autocomplete="current-password" />
    </div>
    <button class="btn btn-primary w-100 d-flex align-items-center justify-content-center" :disabled="loading">
      <span v-if="loading" class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
      Войти
    </button>
    <div v-if="error" class="alert alert-danger mt-3 text-center">{{ error }}</div>
  </form>
</template>

<script setup>
import { ref } from 'vue'
const emit = defineEmits(['login'])
const username = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)

async function onLogin() {
  error.value = ''
  loading.value = true
  try {
    await emit('login', { username: username.value, password: password.value, setError: (msg) => error.value = msg })
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-form {
  padding: 40px;
  max-width: 400px;
  margin: 0 auto;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 24px rgba(102, 126, 234, 0.08);
}
.login-form h2 {
  text-align: center;
  margin-bottom: 30px;
  color: #2c3e50;
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
.form-group input {
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
</style> 