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
  </div>
</template>

<script setup>
const props = defineProps({
  stats: {
    type: Object,
    required: true
  }
})
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
.stat-card h3 {
  font-size: 2.5em;
  margin-bottom: 10px;
}
.stat-card p {
  opacity: 0.9;
  font-size: 1.1em;
}
@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
}
</style> 