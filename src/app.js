const express = require('express')
const cors = require('cors')
const helmet = require('helmet')

const app = express()

// Middleware
app.use(helmet())
app.use(cors())
app.use(express.json())

// Health check route
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'arrivio-api',
    timestamp: new Date().toISOString()
  })
})

module.exports = app