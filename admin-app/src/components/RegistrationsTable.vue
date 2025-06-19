<template>
  <div>
    <table class="registrations-table">
      <thead>
        <tr>
          <th>ФИО</th>
          <th>Email</th>
          <th>Телефон</th>
          <th>Город</th>
          <th>Церковь</th>
          <th>Жилье</th>
          <th>Telegram</th>
          <th>Дата</th>
          <th>Отменён</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="user in users" :key="user.id" :style="user.cancelled_at ? 'background:#f0f0f0;color:#888;' : ''">
          <td>{{ user.cancelled_at ? '🚫 ' : '' }}{{ user.full_name || '-' }}</td>
          <td>{{ user.email || '-' }}</td>
          <td>{{ user.phone || '-' }}</td>
          <td>{{ user.city || '-' }}</td>
          <td>{{ user.church_name || '-' }}</td>
          <td>{{ user.need_accommodation ? 'Да' : 'Нет' }}</td>
          <td>{{ user.telegram_username || '-' }}</td>
          <td>{{ user.registration_date ? new Date(user.registration_date).toLocaleDateString('ru-RU') : '-' }}</td>
          <td>{{ user.cancelled_at ? 'Да' : 'Нет' }}</td>
          <td>
            <button v-if="!user.cancelled_at" @click="$emit('cancel', user.id)">Отменить</button>
          </td>
        </tr>
      </tbody>
    </table>
    <div v-if="!users.length" class="loading">Нет зарегистрированных пользователей</div>
  </div>
</template>

<script setup>
const props = defineProps({
  users: {
    type: Array,
    required: true
  }
})
</script>

<style scoped>
.registrations-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 5px 15px rgba(0,0,0,0.1);
}
.registrations-table th,
.registrations-table td {
  padding: 15px;
  text-align: left;
  border-bottom: 1px solid #e1e8ed;
}
.registrations-table th {
  background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
  color: white;
  font-weight: 600;
}
.registrations-table tr:hover {
  background: #f8f9fa;
}
.loading {
  text-align: center;
  padding: 40px;
  color: #7f8c8d;
}
@media (max-width: 768px) {
  .registrations-table {
    font-size: 14px;
  }
  .registrations-table th,
  .registrations-table td {
    padding: 10px;
  }
}
</style> 