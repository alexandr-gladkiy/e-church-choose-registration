<template>
  <form class="change-password-form" @submit.prevent="onChangePassword">
    <h3>Сменить пароль</h3>
    <div class="form-group">
      <label>Старый пароль:<input v-model="oldPassword" type="password" required></label>
    </div>
    <div class="form-group">
      <label>Новый пароль:<input v-model="newPassword" type="password" required></label>
    </div>
    <button class="btn">Сменить</button>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="success" class="success">{{ success }}</div>
  </form>
</template>

<script setup>
import { ref } from 'vue'
const emit = defineEmits(['change-password'])
const oldPassword = ref('')
const newPassword = ref('')
const error = ref('')
const success = ref('')

async function onChangePassword() {
  error.value = ''
  success.value = ''
  if (!oldPassword.value || !newPassword.value) {
    error.value = 'Заполните оба поля'
    return
  }
  await emit('change-password', {
    oldPassword: oldPassword.value,
    newPassword: newPassword.value,
    setError: (msg) => error.value = msg,
    setSuccess: (msg) => success.value = msg
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