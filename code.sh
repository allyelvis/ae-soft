#!/bin/bash

# Project Name
PROJECT_NAME="accounting_pos_wallet_system"
DB_NAME="accounting_pos_wallet_db"
DB_USER="db_user"
DB_PASSWORD="your_secure_password"

# Step 1: Install necessary software

echo "Installing Node.js, PostgreSQL, and other dependencies..."

# Update and install Node.js, PostgreSQL
sudo apt update
sudo apt install -y nodejs npm postgresql postgresql-contrib

# Step 2: Set up PostgreSQL database

echo "Setting up PostgreSQL database..."

sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
sudo -u postgres psql -c "ALTER ROLE $DB_USER SET client_encoding TO 'utf8';"
sudo -u postgres psql -c "ALTER ROLE $DB_USER SET default_transaction_isolation TO 'read committed';"
sudo -u postgres psql -c "ALTER ROLE $DB_USER SET timezone TO 'UTC';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

# Step 3: Set up Node.js project

echo "Setting up Node.js project..."

# Create project directory
mkdir $PROJECT_NAME && cd $PROJECT_NAME

# Initialize Node.js project
npm init -y

# Install necessary npm packages
npm install express pg sequelize jsonwebtoken bcryptjs axios dotenv --save

# Step 4: Create project structure

echo "Creating project structure..."

# Create basic folder structure
mkdir -p src/{controllers,models,routes,middleware,config}

# Step 5: Initialize Sequelize for PostgreSQL ORM

echo "Initializing Sequelize ORM..."

npx sequelize-cli init

# Update config/config.json for PostgreSQL connection
cat > src/config/config.js << EOL
module.exports = {
  development: {
    username: "$DB_USER",
    password: "$DB_PASSWORD",
    database: "$DB_NAME",
    host: "127.0.0.1",
    dialect: "postgres"
  },
  production: {
    username: "$DB_USER",
    password: "$DB_PASSWORD",
    database: "$DB_NAME",
    host: "127.0.0.1",
    dialect: "postgres"
  }
};
EOL

# Step 6: Create Models for Accounting, POS, and Wallet System

echo "Creating models for accounting, POS, and wallet..."

# Accounting model
cat > src/models/accounting.js << EOL
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Accounting = sequelize.define('Accounting', {
  invoice_id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  amount: {
    type: DataTypes.FLOAT,
    allowNull: false,
  },
  description: {
    type: DataTypes.STRING,
  },
  status: {
    type: DataTypes.STRING,
    defaultValue: 'pending',
  },
});

module.exports = Accounting;
EOL

# POS model
cat > src/models/pos.js << EOL
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const POS = sequelize.define('POS', {
  transaction_id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  item: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  price: {
    type: DataTypes.FLOAT,
    allowNull: false,
  },
  quantity: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  total: {
    type: DataTypes.FLOAT,
    allowNull: false,
  }
});

module.exports = POS;
EOL

# Digital Wallet model
cat > src/models/wallet.js << EOL
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Wallet = sequelize.define('Wallet', {
  user_id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  balance: {
    type: DataTypes.FLOAT,
    defaultValue: 0.0,
  },
  card_number: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  expiry_date: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  cvv: {
    type: DataTypes.STRING,
    allowNull: false,
  },
});

module.exports = Wallet;
EOL

# Step 7: Set up basic Express.js server

echo "Setting up Express.js server..."

cat > src/index.js << EOL
require('dotenv').config();
const express = require('express');
const sequelize = require('./config/database');
const app = express();

app.use(express.json());

// Test route
app.get('/', (req, res) => {
  res.send('Accounting, POS, and Wallet System is running...');
});

// Sync database and start server
sequelize.sync()
  .then(() => {
    console.log('Database synced');
    app.listen(3000, () => {
      console.log('Server running on port 3000');
    });
  })
  .catch((err) => {
    console.error('Error syncing database: ', err);
  });
EOL

# Step 8: Visa API Integration (Stub Example)

echo "Adding Visa API integration example..."

cat > src/controllers/visaController.js << EOL
const axios = require('axios');

exports.processVisaPayment = async (req, res) => {
  const { amount, currency, card_number, expiry_date, cvv } = req.body;

  // Simulate Visa payment API request
  try {
    const response = await axios.post('https://api.visa.com/payments', {
      amount,
      currency,
      card_number,
      expiry_date,
      cvv
    });

    return res.status(200).json({
      transaction_id: response.data.transaction_id,
      status: response.data.status
    });
  } catch (error) {
    return res.status(400).json({ error: 'Payment failed', details: error.message });
  }
};
EOL

# Add route for Visa payment
cat > src/routes/visaRoutes.js << EOL
const express = require('express');
const { processVisaPayment } = require('../controllers/visaController');
const router = express.Router();

router.post('/visa/payment', processVisaPayment);

module.exports = router;
EOL

# Include route in main server file
echo "Adding Visa route to main server..."

sed -i "s|app.use(express.json());|app.use(express.json());\napp.use('/api', require('./routes/visaRoutes'));|" src/index.js

# Step 9: Run the server

echo "Running the Node.js server..."

node src/index.js

echo "System setup complete! The system is running at http://localhost:3000"