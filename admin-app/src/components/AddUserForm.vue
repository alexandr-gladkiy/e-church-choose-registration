<template>
  <form class="add-user-form" @submit.prevent="onAddUser">
    <h3>Добавить участника</h3>
    <div class="form-group"><label>ФИО:<input v-model="fullName" type="text" required></label></div>
    <div class="form-group"><label>Email:<input v-model="email" type="email"></label></div>
    <div class="form-group"><label>Телефон:<input v-model="phone" type="text"></label></div>
    <div class="form-group"><label>Город:<input v-model="city" type="text" required></label></div>
    <div class="form-group"><label>Церковь:<input v-model="churchName" type="text" required></label></div>
    <div class="form-group"><label>Нужна гостиница: <input v-model="needAccommodation" type="checkbox"></label></div>
    <div class="form-group"><label>Комментарий:<input v-model="comments" type="text"></label></div>
    <div class="form-group"><label>Telegram ID:<input v-model="telegramId" type="text"></label></div>
    <div class="form-group"><label>Telegram username:<input v-model="telegramUsername" type="text"></label></div>
    <button class="btn">Зарегистрировать</button>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="success" class="success">{{ success }}</div>
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

async function onAddUser() {
  error.value = ''
  success.value = ''
  if (!fullName.value || !city.value || !churchName.value) {
    error.value = 'Поля ФИО, Город и Церковь обязательны'
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
    setError: (msg) => error.value = msg,
    setSuccess: (msg) => success.value = msg
  })
}
</script>

<style scoped>
.add-user-form {
  padding: 40px;
  max-width: 600px;
  margin: 0 auto 30px auto;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 24px rgba(102, 126, 234, 0.08);
}
.add-user-form h3 {
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
.form-group input[type="text"],
.form-group input[type="email"] {
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