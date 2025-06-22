<template>
  <div>
    <div class="mb-3 d-flex flex-wrap gap-2 align-items-center">
      <input v-model="search" class="form-control w-auto" placeholder="Поиск по ФИО, email, телефону..." />
    </div>
    <table class="table table-bordered table-hover align-middle bg-white">
      <thead class="table-dark">
        <tr>
          <th @click="sort('full_name')" style="cursor:pointer">ФИО <span v-if="sortBy==='full_name'">{{ sortDir==='asc' ? '▲' : '▼' }}</span></th>
          <th @click="sort('email')" style="cursor:pointer">Email <span v-if="sortBy==='email'">{{ sortDir==='asc' ? '▲' : '▼' }}</span></th>
          <th @click="sort('phone')" style="cursor:pointer">Телефон <span v-if="sortBy==='phone'">{{ sortDir==='asc' ? '▲' : '▼' }}</span></th>
          <th @click="sort('city')" style="cursor:pointer">Город <span v-if="sortBy==='city'">{{ sortDir==='asc' ? '▲' : '▼' }}</span></th>
          <th @click="sort('church_name')" style="cursor:pointer">Церковь <span v-if="sortBy==='church_name'">{{ sortDir==='asc' ? '▲' : '▼' }}</span></th>
          <th>Жилье</th>
          <th>Telegram</th>
          <th @click="sort('registration_date')" style="cursor:pointer">Дата <span v-if="sortBy==='registration_date'">{{ sortDir==='asc' ? '▲' : '▼' }}</span></th>
          <th>Отменён</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="user in paginated" :key="user.id" :class="user.cancelled_at ? 'table-secondary text-muted' : ''">
          <td>{{ user.cancelled_at ? '🚫 ' : '' }}{{ user.full_name || '-' }}</td>
          <td>{{ user.email || '-' }}</td>
          <td>{{ user.phone || '-' }}</td>
          <td>{{ user.city || '-' }}</td>
          <td>{{ user.church_name || '-' }}</td>
          <td>{{ user.need_accommodation ? 'Да' : 'Нет' }}</td>
          <td>{{ user.telegram_username || '-' }}</td>
          <td>{{ user.registration_date ? new Date(user.registration_date).toLocaleDateString('ru-RU') : '-' }}</td>
          <td>{{ user.cancelled_at ? 'Да' : 'Нет' }}</td>
          <td>
            <div class="btn-group" role="group">
              <button v-if="!user.cancelled_at" class="btn btn-sm btn-outline-danger" @click="confirmCancel(user.id)">Отменить</button>
              <button class="btn btn-sm btn-outline-danger" @click="confirmDelete(user.id, user.full_name)">Удалить</button>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
    <div v-if="!filtered.length" class="text-center text-muted py-4">Нет зарегистрированных пользователей</div>
    <nav v-if="pages > 1" class="mt-3">
      <ul class="pagination justify-content-center">
        <li class="page-item" :class="{disabled: page===1}">
          <button class="page-link" @click="page=page-1" :disabled="page===1">Назад</button>
        </li>
        <li class="page-item" v-for="p in pages" :key="p" :class="{active: p===page}">
          <button class="page-link" @click="page=p">{{p}}</button>
        </li>
        <li class="page-item" :class="{disabled: page===pages}">
          <button class="page-link" @click="page=page+1" :disabled="page===pages">Вперёд</button>
        </li>
      </ul>
    </nav>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
const props = defineProps({
  users: {
    type: Array,
    required: true
  }
})
const search = ref('')
const sortBy = ref('registration_date')
const sortDir = ref('desc')
const page = ref(1)
const pageSize = 10

const filtered = computed(() => {
  if (!search.value) return props.users
  const s = search.value.toLowerCase()
  return props.users.filter(u =>
    (u.full_name && u.full_name.toLowerCase().includes(s)) ||
    (u.email && u.email.toLowerCase().includes(s)) ||
    (u.phone && u.phone.toLowerCase().includes(s))
  )
})

const sorted = computed(() => {
  return [...filtered.value].sort((a, b) => {
    let av = a[sortBy.value] || ''
    let bv = b[sortBy.value] || ''
    if (sortBy.value === 'registration_date') {
      av = new Date(av)
      bv = new Date(bv)
    }
    if (av < bv) return sortDir.value === 'asc' ? -1 : 1
    if (av > bv) return sortDir.value === 'asc' ? 1 : -1
    return 0
  })
})

const pages = computed(() => Math.ceil(sorted.value.length / pageSize))
const paginated = computed(() => {
  const start = (page.value - 1) * pageSize
  return sorted.value.slice(start, start + pageSize)
})

function sort(field) {
  if (sortBy.value === field) {
    sortDir.value = sortDir.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortBy.value = field
    sortDir.value = 'asc'
  }
}

function confirmCancel(id) {
  if (window.confirm('Вы уверены, что хотите отменить регистрацию этого пользователя?')) {
    emit('cancel', id)
  }
}

function confirmDelete(id, full_name) {
  if (window.confirm(`Вы уверены, что хотите удалить пользователя "${full_name}"?`)) {
    emit('delete', id)
  }
}

const emit = defineEmits(['cancel', 'delete'])
</script>

<style scoped>
.table th {
  user-select: none;
}
</style> 