const express = require('express');
const userRoutes = require('./routes/userRoutes');
require('dotenv').config();
const sequelize = require('./config/db');

const app = express();

app.use(express.json());

// Routes
app.use('/api/users', userRoutes);

// Sync Database
sequelize.sync()
  .then(() => {
    app.listen(5000, () => console.log('Server running on port 5000'));
  })
  .catch(err => console.log(err));
