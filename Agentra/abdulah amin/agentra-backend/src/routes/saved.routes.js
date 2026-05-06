const express = require('express');
const router = express.Router();

const protect = require('../middleware/auth.middleware');
const optionalAuth = require('../middleware/optional-auth.middleware');
const savedController = require('../controllers/saved.controller');

router.post('/:packageId', protect, savedController.savePackage);
router.delete('/:packageId', protect, savedController.unsavePackage);
router.get('/:packageId/check', optionalAuth, savedController.checkIsSaved);
router.put('/:packageId/notes', protect, savedController.updateSavedNotes);
router.get('/stats/me', protect, savedController.getSavedStats);
router.get('/', protect, savedController.getSavedPackages);

module.exports = router;
