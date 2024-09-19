#!/bin/bash

# Exit on any error


# Project name
PROJECT_NAME="accounting-pos-wallet-system"
BACKEND_DIR="backend"
FRONTEND_DIR="frontend"

# GitHub repository URL (replace with your repo URL)
GITHUB_REPO_URL="https://github.com/allyelvis/$PROJECT_NAME.git"

# Function to print messages
print_message() {
    echo
    echo "==================================="
    echo "$1"
    echo "==================================="
    echo
}

# 1. Create Project Directory
print_message "Creating project directory: $PROJECT_NAME"
mkdir $PROJECT_NAME
cd $PROJECT_NAME

# 2. Backend Setup: Node.js + Express + PostgreSQL
print_message "Setting up the backend with Node.js, Express, and PostgreSQL"

# Create backend folder and initialize Node.js project
mkdir $BACKEND_DIR
cd $BACKEND_DIR
npm init -y

# Install necessary backend packages
npm install express pg sequelize bcrypt jsonwebtoken dotenv

# Install development dependencies
npm install --save-dev nodemon eslint

# Create backend directory structure
mkdir -p config controllers models routes middleware

# Create environment file
cat <<EOL > .env
DB_NAME=your_db_name
DB_USER=your_db_user
DB_PASS=your_db_password
DB_HOST=localhost
JWT_SECRET=your_jwt_secret
EOL

# Create Sequelize DB connection config (db.js)
cat <<EOL > config/db.js
const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASS, {
  host: process.env.DB_HOST,
  dialect: 'postgres'
});

sequelize.authenticate()
  .then(() => console.log('Database connected...'))
  .catch(err => console.log('Error: ' + err));

module.exports = sequelize;
EOL

# Create User model (User.js)
cat <<EOL > models/User.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const User = sequelize.define('User', {
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false
  }
}, {
  timestamps: true
});

module.exports = User;
EOL

# Create User controller (userController.js)
cat <<EOL > controllers/userController.js
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

exports.register = async (req, res) => {
  const { name, email, password } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create({ name, email, password: hashedPassword });

    res.json({ message: 'User registered successfully', user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.login = async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ where: { email } });
    if (!user) return res.status(400).json({ message: 'Invalid credentials' });

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(400).json({ message: 'Invalid credentials' });

    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });

    res.json({ token });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
EOL

# Create User routes (userRoutes.js)
cat <<EOL > routes/userRoutes.js
const express = require('express');
const { register, login } = require('../controllers/userController');

const router = express.Router();

router.post('/register', register);
router.post('/login', login);

module.exports = router;
EOL

# Create middleware (auth.js)
cat <<EOL > middleware/auth.js
const jwt = require('jsonwebtoken');
require('dotenv').config();

exports.authMiddleware = (req, res, next) => {
  const token = req.header('Authorization');

  if (!token) return res.status(401).json({ message: 'Access denied' });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    res.status(400).json({ message: 'Invalid token' });
  }
};
EOL

# Create Express server setup (server.js)
cat <<EOL > server.js
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
EOL

# Go back to the root folder
cd ..

# 3. Frontend Setup: React
print_message "Setting up the frontend with React"

# Create frontend folder and initialize React project
npx create-react-app $FRONTEND_DIR

# Install axios for API requests
cd $FRONTEND_DIR
npm install axios

# Go back to the root folder
cd ..

# 4. Initialize Git and Push to GitHub
print_message "Initializing Git repository"

# Initialize Git and add remote origin
git init
git remote add origin $GITHUB_REPO_URL

# Add all files, commit, and push to GitHub
git add .
git commit -m "Initial commit: setup of backend and frontend"
git branch -M main
git push -u origin main

print_message "Project setup complete! The repository has been pushed to GitHub."