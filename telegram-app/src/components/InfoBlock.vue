<template>
  <div class="info-block">
    <div class="info-content">
      <div class="info-item">
        <div class="info-icon">📅</div>
        <div class="info-text">
          <h3>Дата проведения</h3>
          <p>15-17 декабря 2024 года</p>
        </div>
      </div>
      
      <div class="info-item">
        <div class="info-icon">💝</div>
        <div class="info-text">
          <h3>Рекомендуемое пожертвование</h3>
          <p>2000 рублей</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'InfoBlock'
}
</script>

<style scoped>
.info-block {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  /* border-radius: 20px; */
  padding: 30px;
  margin-bottom: 0;
  box-shadow: 
    0 20px 40px rgba(0, 0, 0, 0.3),
    0 0 0 1px rgba(255, 255, 255, 0.1);
  width: 100%;
  max-width: 800px;
  margin-left: auto;
  margin-right: auto;
}

.info-content {
  display: flex;
  gap: 40px;
  justify-content: space-around;
  align-items: center;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 20px;
  flex: 1;
  justify-content: center;
}

.info-icon {
  font-size: 2.5rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  color: white;
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

.info-text h3 {
  margin: 0 0 8px 0;
  color: #333;
  font-size: 1.1rem;
  font-weight: 600;
}

.info-text p {
  margin: 0;
  color: #667eea;
  font-size: 1.2rem;
  font-weight: 700;
}

/* Адаптивность для мобильных устройств */
@media (max-width: 768px) {
  .info-block {
    padding: 20px;
    margin-bottom: 0;
  }
  
  .info-content {
    flex-direction: row;
    gap: 20px;
  }
  
  .info-item {
    flex-direction: row;
    text-align: left;
    gap: 15px;
  }
  
  .info-icon {
    font-size: 1.8rem;
    width: 45px;
    height: 45px;
  }
  
  .info-text h3 {
    font-size: 0.9rem;
  }
  
  .info-text p {
    font-size: 1rem;
  }
}
</style> 