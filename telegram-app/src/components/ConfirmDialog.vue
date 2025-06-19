<template>
  <div v-if="show" class="confirm-dialog-overlay" @click="handleOverlayClick">
    <div class="confirm-dialog" @click.stop>
      <div class="dialog-header">
        <h3>Подтверждение регистрации</h3>
      </div>
      
      <div class="dialog-content">
        <p>Вы действительно желаете зарегистрироваться на мероприятие?</p>
        
        <div class="registration-summary">
          <div class="summary-item">
            <strong>Имя:</strong> {{ registrationData.fullName }}
          </div>
          <div class="summary-item">
            <strong>Город:</strong> {{ registrationData.city }}
          </div>
          <div class="summary-item">
            <strong>Церковь:</strong> {{ registrationData.churchName }}
          </div>
          <div v-if="registrationData.needAccommodation" class="summary-item">
            <strong>Расселение:</strong> Нужно
          </div>
          <div v-if="registrationData.comments" class="summary-item">
            <strong>Комментарии:</strong> {{ registrationData.comments }}
          </div>
        </div>
      </div>
      
      <div class="dialog-actions">
        <button 
          type="button" 
          class="btn-cancel" 
          @click="handleCancel"
          :disabled="isLoading"
        >
          Отмена
        </button>
        <button 
          type="button" 
          class="btn-confirm" 
          @click="handleConfirm"
          :disabled="isLoading"
        >
          <span v-if="!isLoading">Да, зарегистрироваться</span>
          <span v-else class="btn-loading">
            <div class="spinner"></div>
            Регистрация...
          </span>
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConfirmDialog',
  props: {
    show: {
      type: Boolean,
      default: false
    },
    registrationData: {
      type: Object,
      required: true
    },
    isLoading: {
      type: Boolean,
      default: false
    }
  },
  emits: ['confirm', 'cancel'],
  setup(props, { emit }) {
    const handleConfirm = () => {
      emit('confirm')
    }
    
    const handleCancel = () => {
      emit('cancel')
    }
    
    const handleOverlayClick = () => {
      if (!props.isLoading) {
        emit('cancel')
      }
    }
    
    return {
      handleConfirm,
      handleCancel,
      handleOverlayClick
    }
  }
}
</script>

<style scoped>
.confirm-dialog-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  padding: 20px;
}

.confirm-dialog {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 30px;
  max-width: 500px;
  width: 100%;
  box-shadow: 
    0 20px 40px rgba(0, 0, 0, 0.3),
    0 0 0 1px rgba(255, 255, 255, 0.1);
  animation: dialogSlideIn 0.3s ease-out;
}

@keyframes dialogSlideIn {
  from {
    opacity: 0;
    transform: translateY(-20px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.dialog-header {
  margin-bottom: 20px;
  text-align: center;
}

.dialog-header h3 {
  margin: 0;
  color: #333;
  font-size: 1.3rem;
  font-weight: 600;
}

.dialog-content {
  margin-bottom: 25px;
}

.dialog-content p {
  margin: 0 0 20px 0;
  color: #555;
  font-size: 1rem;
  text-align: center;
}

.registration-summary {
  background: rgba(102, 126, 234, 0.1);
  border-radius: 12px;
  padding: 20px;
  border: 1px solid rgba(102, 126, 234, 0.2);
}

.summary-item {
  margin-bottom: 10px;
  font-size: 0.95rem;
  color: #333;
}

.summary-item:last-child {
  margin-bottom: 0;
}

.summary-item strong {
  color: #667eea;
  font-weight: 600;
}

.dialog-actions {
  display: flex;
  gap: 15px;
  justify-content: center;
}

.btn-cancel,
.btn-confirm {
  padding: 12px 24px;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
  min-width: 140px;
}

.btn-cancel {
  background: rgba(108, 117, 125, 0.1);
  color: #6c757d;
  border: 2px solid rgba(108, 117, 125, 0.3);
}

.btn-cancel:hover:not(:disabled) {
  background: rgba(108, 117, 125, 0.2);
  border-color: rgba(108, 117, 125, 0.5);
}

.btn-confirm {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.btn-confirm:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.btn-cancel:disabled,
.btn-confirm:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.btn-loading {
  display: flex;
  align-items: center;
  gap: 8px;
  justify-content: center;
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Адаптивность для мобильных устройств */
@media (max-width: 768px) {
  .confirm-dialog {
    padding: 20px;
    margin: 10px;
  }
  
  .dialog-header h3 {
    font-size: 1.2rem;
  }
  
  .dialog-content p {
    font-size: 0.95rem;
  }
  
  .registration-summary {
    padding: 15px;
  }
  
  .summary-item {
    font-size: 0.9rem;
  }
  
  .dialog-actions {
    flex-direction: column;
    gap: 10px;
  }
  
  .btn-cancel,
  .btn-confirm {
    width: 100%;
    min-width: auto;
  }
}
</style> 