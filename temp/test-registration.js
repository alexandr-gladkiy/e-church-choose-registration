const axios = require('axios');

async function testRegistration() {
  try {
    console.log('Тестируем API регистрации...');
    
    // Тест 1: Проверяем настройки регистрации
    console.log('\n1. Проверяем настройки регистрации...');
    const settingsResponse = await axios.get('http://localhost:3000/api/registration-settings');
    console.log('Настройки:', settingsResponse.data);
    
    // Тест 2: Пробуем зарегистрировать пользователя
    console.log('\n2. Пробуем зарегистрировать пользователя...');
    const testUser = {
      full_name: 'Тестовый Пользователь',
      email: 'test@example.com',
      phone: '+7 (999) 123-45-67',
      city: 'Москва',
      church_name: 'Тестовая Церковь',
      need_accommodation: false,
      comments: 'Тестовая регистрация',
      telegram_id: 123456789,
      telegram_username: 'testuser'
    };
    
    const registrationResponse = await axios.post('http://localhost:3000/api/users', testUser);
    console.log('Регистрация успешна:', registrationResponse.data);
    
  } catch (error) {
    console.error('Ошибка:', error.response?.data || error.message);
    console.error('Статус:', error.response?.status);
  }
}

testRegistration(); 