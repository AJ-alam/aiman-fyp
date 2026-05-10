const express = require('express');
const router = express.Router();

const protect = require('../middleware/auth.middleware');
const role = require('../middleware/role.middleware');
const complaintsController = require('../controllers/complaints.controller');
const Complaint = require('../models/Complaint');

// =============== GET ALL COMPLAINTS (OWNER) ===============
router.get('/', protect, role('OWNER'), complaintsController.getAllComplaints);

// =============== UPDATE COMPLAINT STATUS (OWNER) ===============
router.put('/:id', protect, role('OWNER'), complaintsController.updateComplaintStatus);

// =============== AGENT SUBMITS COMPLAINT TO ADMIN ===============
router.post('/agent', protect, role('AGENT'), async (req, res) => {
  try {
    const { subject, description } = req.body;
    const complaint = await Complaint.create({
      agentId: req.user.id,
      userId: req.user.id, // agent is the complainant
      subject,
      description,
      status: 'OPEN'
    });
    res.status(201).json({ success: true, complaint });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;