// src/api.js
const API_BASE = '/api'

export async function login(username, password) {
  const response = await fetch(`${API_BASE}/admins/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password })
  })
  return response.json()
}

export async function fetchUsers() {
  const response = await fetch(`${API_BASE}/users`)
  return response.json()
}

export async function addUser(user) {
  const response = await fetch(`${API_BASE}/users`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(user)
  })
  return response.json()
}

export async function cancelRegistration(userId) {
  const response = await fetch(`${API_BASE}/users/${userId}/cancel`, { method: 'POST' })
  return response.json()
}

export async function exportCSV() {
  const response = await fetch(`${API_BASE}/users/export`)
  return response.blob()
}

export async function changePassword(oldPassword, newPassword) {
  const response = await fetch(`${API_BASE}/admins/change-password`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ oldPassword, newPassword })
  })
  return response.json()
} 