import axios from 'axios'

// Создаем экземпляр axios с базовыми настройками
const api = axios.create({
  baseURL: 'http://localhost:3000',  // Прямое обращение к backend-api
  headers: {
    'Content-Type': 'application/json'
  }
})

// Добавляем перехватчик для логирования запросов
api.interceptors.request.use(request => {
  console.log('Starting Request:', {
    url: request.url,
    method: request.method,
    data: request.data
  })
  return request
})

// Добавляем перехватчик для логирования ответов
api.interceptors.response.use(
  response => {
    console.log('Response:', {
      status: response.status,
      data: response.data
    })
    return response
  },
  error => {
    console.error('Response Error:', {
      message: error.message,
      response: error.response?.data
    })
    return Promise.reject(error)
  }
)

export default api 