const express = require('express');
const router = express.Router();

const protect = require('../middleware/auth.middleware');
const role = require('../middleware/role.middleware');
const packageController = require('../controllers/package.controller');

router.get('/', packageController.getPublicPackages);
router.get('/agent', protect, role('AGENT'), packageController.getAgentPackages);
router.get('/all/admin', protect, role('OWNER'), packageController.getAllPackages);
// Temporary cleanup route kept for maintenance, but never public.
router.delete('/temp-cleanup', protect, role('OWNER'), packageController.cleanupPackages);

router.get('/locations', packageController.getLocations);
router.get('/:id', packageController.getPackageDetails);

router.post('/', protect, role('AGENT'), packageController.createPackage);
router.put('/:id', protect, role('AGENT'), packageController.updatePackage);
router.delete('/:id', protect, role('AGENT'), packageController.deletePackage);
router.patch('/:id/status', protect, role('OWNER'), packageController.togglePackageStatus);

module.exports = router;
