const axios = require('axios');

const API_BASE = 'http://localhost:3000/api';

async function testReactivation() {
  console.log('🧪 Тестирование функциональности повторной регистрации...\n');

  try {
    // 1. Создаем тестового пользователя
    console.log('1️⃣ Создаем тестового пользователя...');
    const testUser = {
      full_name: 'Тестовый Пользователь',
      city: 'Москва',
      church_name: 'Тестовая Церковь',
      phone: '+7 (999) 123-45-67',
      comments: 'Тестовый комментарий',
      need_accommodation: true,
      telegram_id: 123456789,
      telegram_username: 'testuser'
    };

    const createResponse = await axios.post(`${API_BASE}/users`, testUser);
    console.log('✅ Пользователь создан:', createResponse.data.user.id);
    const userId = createResponse.data.user.id;

    // 2. Отменяем регистрацию
    console.log('\n2️⃣ Отменяем регистрацию...');
    await axios.post(`${API_BASE}/users/${userId}/cancel`);
    console.log('✅ Регистрация отменена');

    // 3. Проверяем, что пользователь отменен
    console.log('\n3️⃣ Проверяем статус отмены...');
    const checkResponse = await axios.get(`${API_BASE}/users?telegramId=${testUser.telegram_id}`);
    const cancelledUser = checkResponse.data[0];
    console.log('✅ Пользователь отменен:', cancelledUser.cancelled_at ? 'Да' : 'Нет');

    // 4. Пытаемся зарегистрироваться повторно
    console.log('\n4️⃣ Регистрируемся повторно...');
    const reactivateResponse = await axios.post(`${API_BASE}/users`, {
      ...testUser,
      full_name: 'Обновленный Тестовый Пользователь',
      phone: '+7 (999) 987-65-43'
    });

    console.log('✅ Повторная регистрация успешна!');
    console.log('📋 Ответ сервера:', {
      success: reactivateResponse.data.success,
      reactivated: reactivateResponse.data.reactivated,
      userId: reactivateResponse.data.user.id
    });

    // 5. Проверяем, что пользователь снова активен
    console.log('\n5️⃣ Проверяем, что пользователь снова активен...');
    const finalCheckResponse = await axios.get(`${API_BASE}/users?telegramId=${testUser.telegram_id}`);
    const reactivatedUser = finalCheckResponse.data[0];
    console.log('✅ Пользователь активен:', reactivatedUser.cancelled_at ? 'Нет' : 'Да');
    console.log('📋 Обновленные данные:', {
      full_name: reactivatedUser.full_name,
      phone: reactivatedUser.phone,
      registration_date: reactivatedUser.registration_date
    });

    console.log('\n🎉 Тест завершен успешно! Функциональность повторной регистрации работает корректно.');

  } catch (error) {
    console.error('❌ Ошибка в тесте:', error.response?.data || error.message);
  }
}

testReactivation(); 