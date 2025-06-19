<template>
  <div v-if="message" :class="[type]" class="message">
    {{ message }}
  </div>
</template>

<script setup>
const props = defineProps({
  message: String,
  type: {
    type: String,
    default: 'success' // или 'error'
  }
})
</script>

<style scoped>
.message {
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
  text-align: center;
  font-weight: 500;
}
.success {
  background: #27ae60;
  color: white;
}
.error {
  background: #e74c3c;
  color: white;
}
</style> 