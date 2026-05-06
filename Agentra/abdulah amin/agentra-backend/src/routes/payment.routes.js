const express = require('express');
const router = express.Router();

const protect = require('../middleware/auth.middleware');
const paymentController = require('../controllers/payment.controller');

router.get('/methods', paymentController.getPaymentMethods);
router.post('/intent', protect, paymentController.createPaymentIntent);
router.post('/process', protect, paymentController.processPayment);
router.get('/verify/:transactionId', protect, paymentController.verifyPayment);
router.post('/refund', protect, paymentController.processRefund);
router.get('/history', protect, paymentController.getTransactionHistory);

module.exports = router;