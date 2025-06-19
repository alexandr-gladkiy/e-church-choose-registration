<template>
  <div class="header-block">
    <h1>🎉 Регистрация на конференцию "Выбирай"</h1>
    <p>"Побеждающий наследует всё, и буду ему Богом, и он будет Мне сыном." Откр. 21:7</p>
  </div>
</template>

<script>
export default {
  name: 'HeaderBlock'
}
</script>

<style scoped>
.header-block {
  text-align: center;
  margin-bottom: 0;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px 20px 0 0;
  padding: 30px;
  box-shadow: 
    0 20px 40px rgba(0, 0, 0, 0.3),
    0 0 0 1px rgba(255, 255, 255, 0.1);
  width: 100%;
  max-width: 800px;
  position: relative;
  z-index: 1;
}

.header-block h1 {
  color: #2c3e50;
  font-size: 2em;
  margin-bottom: 0;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.header-block p {
  color: #7f8c8d;
  font-size: 1.1em;
  margin: 0;
}

/* Адаптивность для мобильных устройств */
@media (max-width: 768px) {
  .header-block {
    padding: 20px;
  }
  
  .header-block h1 {
    font-size: 1.6em;
  }
  
  .header-block p {
    font-size: 1em;
  }
}
</style> 