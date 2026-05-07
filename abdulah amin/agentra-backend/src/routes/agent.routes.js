const express = require('express');
const router = express.Router();

const protect = require('../middleware/auth.middleware');
const role = require('../middleware/role.middleware');
const Agent = require('../models/Agent');

router.get('/me', protect, (req, res) => {
  res.json({ success: true, user: req.user });
});

// Compatibility: some clients call /api/agents for owner listing.
router.get('/', protect, role('OWNER'), async (req, res) => {
  try {
    const agents = await Agent.find().select('-password');
    res.json({ success: true, agents });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
