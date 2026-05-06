const express = require('express');
const mongoose = require('mongoose');
const dns = require('dns');
const dotenv = require('dotenv');
const cors = require('cors');
const { registerRoutes } = require('./src/register-routes');

dotenv.config();

const PORT = process.env.PORT || 5000;

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());


app.use((req, res, next) => {
  console.log("🔥 REQUEST HIT:");
  console.log("METHOD:", req.method);
  console.log("URL:", req.originalUrl);
  console.log("PATH:", req.path);
  console.log("BODY:", req.body);
  console.log("-----------------------------");
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

// DB URI
const MONGO_URI = (process.env.MONGO_URI || process.env.MONGODB_URI || '')
  .trim()
  .replace(/^["']|["']$/g, '');

if (!MONGO_URI) {
  console.error('❌ MONGO_URI missing in .env');
}
if (MONGO_URI.startsWith('mongodb+srv://')) {
  console.log('🌐 Using public DNS for Atlas SRV resolution');
  dns.setServers(['8.8.8.8', '1.1.1.1']);
}
// DB Connection
const connectDB = async () => {
  const connect = async (uri) => {
    await mongoose.connect(uri, {
      dbName: 'agentra',
      serverSelectionTimeoutMS: 10000,
      socketTimeoutMS: 45000,
      connectTimeoutMS: 10000,
      retryWrites: true,
    });
  };

  try {
    if (mongoose.connection.readyState >= 1) {
      return;
    }

    console.log('🔄 Connecting to MongoDB...');
    console.log('📍 URI:', MONGO_URI.substring(0, 30) + '...');

    await connect(MONGO_URI);
    console.log('✅ MongoDB Connected Successfully');
    return true;
  } catch (err) {
    console.error('❌ MongoDB Connection Failed:', err.message);

    if (MONGO_URI.includes('localhost') && err.message.includes('ECONNREFUSED')) {
      const fallbackUri = MONGO_URI.replace('localhost', '127.0.0.1');
      console.log('🔁 Retrying MongoDB connection with 127.0.0.1');
      try {
        await connect(fallbackUri);
        console.log('✅ MongoDB Connected Successfully using 127.0.0.1');
        return true;
      } catch (fallbackErr) {
        console.error('❌ MongoDB fallback connection failed:', fallbackErr.message);
      }
    }

    console.error('⚠️  Stack:', err.stack);
    return false;
  }
};

// Initial connection attempt
(async () => {
  const connected = await connectDB();
  if (!connected && process.env.NODE_ENV === 'production') {
    console.error('❌ Failed to connect to MongoDB in production. Exiting...');
    process.exit(1);
  }
})();

// Ensure DB connection before processing requests
app.use(async (req, res, next) => {
  if (mongoose.connection.readyState !== 1) {
    console.log('⚠️  MongoDB disconnected. Attempting reconnection...');
    await connectDB();
  }
  next();
});

// Root route
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Agentra API Running',
  });
});

// Health check route (no auth required)
app.get('/health', (req, res) => {
  res.json({
    success: true,
    status: 'healthy',
    timestamp: new Date().toISOString(),
    mongodb: mongoose.connection.readyState === 1 ? '✅ Connected' : '❌ Disconnected',
    port: PORT,
    environment: process.env.NODE_ENV
  });
});

// Status check route
app.get('/api/status', (req, res) => {
  res.json({
    success: true,
    api: 'Agentra Travel Management System',
    version: '1.0.0',
    status: 'running',
    database: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected',
    timestamp: new Date().toISOString()
  });
});

// ================= ROUTES =================
registerRoutes(app);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({
    success: false,
    message: err.message || 'Server Error',
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on ${PORT}`);
});

module.exports = app;
