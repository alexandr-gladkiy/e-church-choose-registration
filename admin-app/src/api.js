// src/api.js
const API_BASE = import.meta.env.VITE_API_URL || '/api';

function getToken() {
  return localStorage.getItem('token');
}

function authHeaders() {
  const token = getToken();
  return token ? { Authorization: `Bearer ${token}` } : {};
}

async function handleResponse(response) {
  if (!response.ok) {
    let error;
    try {
      error = await response.json();
    } catch {
      error = { error: response.statusText };
    }
    throw error;
  }
  return response.json();
}

export async function login(username, password) {
  const response = await fetch(`${API_BASE}/admins/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password })
  });
  return handleResponse(response);
}

export async function fetchUsers() {
  const response = await fetch(`${API_BASE}/users`, { headers: authHeaders() });
  return handleResponse(response);
}

export async function addUser(user) {
  const response = await fetch(`${API_BASE}/users`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify(user)
  });
  return handleResponse(response);
}

export async function cancelRegistration(userId) {
  const response = await fetch(`${API_BASE}/users/${userId}/cancel`, {
    method: 'POST',
    headers: authHeaders()
  });
  return handleResponse(response);
}

export async function deleteUser(userId) {
  const response = await fetch(`${API_BASE}/users/${userId}`, {
    method: 'DELETE',
    headers: authHeaders()
  });
  return handleResponse(response);
}

export async function exportCSV() {
  const response = await fetch(`${API_BASE}/users/export/csv`, { headers: authHeaders() })
  return response.blob()
}

export async function exportPDF() {
  const response = await fetch(`${API_BASE}/users/export/pdf`, { headers: authHeaders() })
  return response.blob()
}

export async function changePassword(oldPassword, newPassword) {
  const response = await fetch(`${API_BASE}/admins/change-password`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ oldPassword, newPassword })
  });
  return handleResponse(response);
}

export async function getCurrentAdmin() {
  const response = await fetch(`${API_BASE}/admins/me`, { headers: authHeaders() });
  return handleResponse(response);
}

export async function fetchRegistrationSettings() {
  const response = await fetch(`${API_BASE}/registration-settings`);
  return handleResponse(response);
}

export async function updateRegistrationSettings(settings) {
  const response = await fetch(`${API_BASE}/registration-settings`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify(settings)
  });
  return handleResponse(response);
} 