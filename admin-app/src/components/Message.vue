<template>
  <div v-if="message" :class="alertClass" class="alert text-center mb-3" role="alert">
    {{ message }}
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  message: String,
  type: {
    type: String,
    default: 'success' // или 'error', 'info', 'warning'
  }
})

const alertClass = computed(() => {
  switch (props.type) {
    case 'error': return 'alert-danger'
    case 'success': return 'alert-success'
    case 'info': return 'alert-info'
    case 'warning': return 'alert-warning'
    default: return 'alert-secondary'
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