require('dotenv').config();
const express = require('express');
const cors = require('cors');
const usersRouter = require('./routes/users');
const adminsRouter = require('./routes/admins');
const registrationSettingsRouter = require('./routes/registrationSettings');

const app = express();
app.use(cors({ origin: true, credentials: true }));
app.use(express.json());

app.use('/api/users', usersRouter);
app.use('/api/admins', adminsRouter);
app.use('/api/registration-settings', registrationSettingsRouter);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}`);
}); 