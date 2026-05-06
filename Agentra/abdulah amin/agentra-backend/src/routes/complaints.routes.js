const express = require('express');
const router = express.Router();

const protect = require('../middleware/auth.middleware');
const role = require('../middleware/role.middleware');
const complaintsController = require('../controllers/complaints.controller');

// =============== GET ALL COMPLAINTS ===============
router.get('/', protect, role('OWNER'), complaintsController.getAllComplaints);

// =============== UPDATE COMPLAINT STATUS ===============
router.put('/:id', protect, role('OWNER'), complaintsController.updateComplaintStatus);

module.exports = router;