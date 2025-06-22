const axios = require('axios');
const fs = require('fs');

async function testCSVExport() {
  try {
    console.log('Тестируем экспорт CSV...');
    
    // Тест экспорта CSV
    const response = await axios.get('http://localhost:3000/api/users/export/csv', {
      responseType: 'stream'
    });
    
    // Сохраняем CSV в файл для проверки
    const writer = fs.createWriteStream('test_export.csv');
    response.data.pipe(writer);
    
    return new Promise((resolve, reject) => {
      writer.on('finish', () => {
        console.log('CSV экспорт успешен! Файл сохранен как test_export.csv');
        resolve();
      });
      writer.on('error', reject);
    });
    
  } catch (error) {
    console.error('Ошибка экспорта CSV:', error.response?.status, error.response?.data || error.message);
  }
}

testCSVExport(); 