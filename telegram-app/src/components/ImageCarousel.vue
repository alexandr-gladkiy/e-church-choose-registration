<template>
  <div class="image-carousel">
    <div class="carousel-container" ref="carouselContainer">
      <div 
        class="carousel-track" 
        :style="{ transform: `translateX(-${currentIndex * 100}%)` }"
        @touchstart="handleTouchStart"
        @touchmove="handleTouchMove"
        @touchend="handleTouchEnd"
      >
        <div 
          v-for="(image, index) in images" 
          :key="index"
          class="carousel-slide"
        >
          <img :src="image.src" :alt="image.alt" class="carousel-image">
          <div class="slide-overlay">
            <h3 class="slide-title">{{ image.title }}</h3>
            <p class="slide-description">{{ image.description }}</p>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Индикаторы -->
    <div class="carousel-indicators">
      <button 
        v-for="(image, index) in images" 
        :key="index"
        class="indicator"
        :class="{ active: index === currentIndex }"
        @click="goToSlide(index)"
      ></button>
    </div>
    
    <!-- Кнопки навигации -->
    <button class="carousel-btn prev" @click="prevSlide" aria-label="Предыдущий слайд">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M15 18L9 12L15 6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    </button>
    <button class="carousel-btn next" @click="nextSlide" aria-label="Следующий слайд">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M9 18L15 12L9 6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    </button>
  </div>
</template>

<script>
import { ref, onMounted, onUnmounted } from 'vue'

export default {
  name: 'ImageCarousel',
  setup() {
    const currentIndex = ref(0)
    const autoplayInterval = ref(null)
    const carouselContainer = ref(null)
    const touchStartX = ref(0)
    const touchEndX = ref(0)
    
    const images = [
      {
        src: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        alt: 'Поклонение и молитва',
        title: 'Поклонение и молитва',
        description: 'Присоединяйтесь к нам в молитве и поклонении'
      },
      {
        src: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        alt: 'Библейское изучение',
        title: 'Изучение Слова Божьего',
        description: 'Углубляйтесь в Писание вместе с нами'
      },
      {
        src: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        alt: 'Общение и общение',
        title: 'Общение и общение',
        description: 'Стройте отношения в христианском сообществе'
      },
      {
        src: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        alt: 'Служение и миссия',
        title: 'Служение и миссия',
        description: 'Несите Евангелие в мир'
      }
    ]
    
    const nextSlide = () => {
      currentIndex.value = (currentIndex.value + 1) % images.length
      resetAutoplay()
    }
    
    const prevSlide = () => {
      currentIndex.value = currentIndex.value === 0 ? images.length - 1 : currentIndex.value - 1
      resetAutoplay()
    }
    
    const goToSlide = (index) => {
      currentIndex.value = index
      resetAutoplay()
    }
    
    const startAutoplay = () => {
      autoplayInterval.value = setInterval(() => {
        nextSlide()
      }, 5000)
    }
    
    const stopAutoplay = () => {
      if (autoplayInterval.value) {
        clearInterval(autoplayInterval.value)
        autoplayInterval.value = null
      }
    }
    
    const resetAutoplay = () => {
      stopAutoplay()
      startAutoplay()
    }
    
    // Обработка свайпов для мобильных устройств
    const handleTouchStart = (event) => {
      touchStartX.value = event.touches[0].clientX
    }
    
    const handleTouchMove = (event) => {
      touchEndX.value = event.touches[0].clientX
    }
    
    const handleTouchEnd = () => {
      const swipeThreshold = 50
      const diff = touchStartX.value - touchEndX.value
      
      if (Math.abs(diff) > swipeThreshold) {
        if (diff > 0) {
          nextSlide()
        } else {
          prevSlide()
        }
      }
    }
    
    onMounted(() => {
      startAutoplay()
    })
    
    onUnmounted(() => {
      stopAutoplay()
    })
    
    return {
      currentIndex,
      images,
      carouselContainer,
      nextSlide,
      prevSlide,
      goToSlide,
      handleTouchStart,
      handleTouchMove,
      handleTouchEnd
    }
  }
}
</script>

<style scoped>
.image-carousel {
  position: relative;
  /* width: 100%; */
  width: 100%;
  max-width: 800px;
  height: 300px;
  overflow: hidden;
  /* border-radius: 12px; */
  margin-bottom: 0;
  margin-left: auto;
  margin-right: auto;
}

.carousel-container {
  width: 100%;
  height: 100%;
  position: relative;
}

.carousel-track {
  display: flex;
  width: 100%;
  height: 100%;
  transition: transform 0.5s ease-in-out;
}

.carousel-slide {
  min-width: 100%;
  position: relative;
  overflow: hidden;
}

.carousel-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center;
}

.slide-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(transparent, rgba(0, 0, 0, 0.7));
  color: white;
  padding: 40px 20px;
  text-align: center;
}

.slide-title {
  margin: 0 0 8px 0;
  font-size: 1.5rem;
  font-weight: 600;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
}

.slide-description {
  margin: 0;
  font-size: 1rem;
  opacity: 0.9;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
}

.carousel-indicators {
  position: absolute;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 8px;
  z-index: 10;
}

.indicator {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  border: 2px solid white;
  background: transparent;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.indicator.active {
  background: white;
  transform: scale(1.2);
}

.indicator:hover {
  background: rgba(255, 255, 255, 0.7);
}

.carousel-btn {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(255, 255, 255, 0.9);
  border: none;
  border-radius: 50%;
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
  z-index: 10;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.carousel-btn:hover {
  background: white;
  transform: translateY(-50%) scale(1.1);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.2);
}

.carousel-btn.prev {
  left: 16px;
}

.carousel-btn.next {
  right: 16px;
}

.carousel-btn svg {
  color: #333;
}

/* Адаптивность для мобильных устройств */
@media (max-width: 768px) {
  .image-carousel {
    height: 250px;
    max-width: 100%;
    /* width: 100%; */
  }
  
  .slide-title {
    font-size: 1.2rem;
  }
  
  .slide-description {
    font-size: 0.9rem;
  }
  
  .carousel-btn {
    width: 40px;
    height: 40px;
  }
  
  .carousel-btn.prev {
    left: 8px;
  }
  
  .carousel-btn.next {
    right: 8px;
  }
}
</style> 