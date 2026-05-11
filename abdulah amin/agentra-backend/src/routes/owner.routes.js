const express = require('express');
const router = express.Router();

const protect = require('../middleware/auth.middleware');
const role = require('../middleware/role.middleware');
const ownerController = require('../controllers/owner.controller');

// ================= AGENTS =================
router.get('/agents', protect, role('OWNER'), ownerController.getAgents);
router.put('/agents/:id/verify', protect, role('OWNER'), ownerController.verifyAgent);
router.put('/agents/:id/block', protect, role('OWNER'), ownerController.blockAgent);
router.put('/agents/:id/unblock', protect, role('OWNER'), ownerController.unblockAgent);
router.delete('/agents/:id/reject', protect, role('OWNER'), ownerController.rejectAgent);

// ================= COMPLAINTS =================
router.get('/complaints', protect, role('OWNER'), ownerController.getComplaints);
router.put('/complaints/:id/respond', protect, role('OWNER'), ownerController.respondComplaint);

// ================= DASHBOARD =================
router.get('/dashboard', protect, role('OWNER'), ownerController.getDashboardStats);

module.exports = router;
