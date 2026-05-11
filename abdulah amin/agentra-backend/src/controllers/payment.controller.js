const Booking = require('../models/Booking');
const Transaction = require('../models/Transaction');
const Package = require('../models/Package');
const User = require('../models/User');
const Agent = require('../models/Agent');

exports.createPaymentIntent = async (req, res) => {
  try {
    const { bookingId, paymentMethod } = req.body;
    const userId = req.user.id;

    const booking = await Booking.findById(bookingId)
      .populate('packageId');

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    if (booking.userId.toString() !== userId.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    if (booking.paymentStatus === 'PAID') {
      return res.status(400).json({
        success: false,
        message: 'Booking already paid'
      });
    }

    const paymentIntentId = `PI-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

    res.json({
      success: true,
      paymentIntent: {
        id: paymentIntentId,
        amount: booking.totalAmount,
        currency: 'PKR',
        paymentMethod,
        status: 'requires_payment_method',
        bookingId: booking._id
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

exports.processPayment = async (req, res) => {
  try {
    const { bookingId, paymentMethod, paymentDetails } = req.body;
    const userId = req.user.id;

    const booking = await Booking.findById(bookingId)
      .populate('packageId')
      .populate('agentId');

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    if (booking.userId.toString() !== userId.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    if (booking.paymentStatus === 'PAID') {
      return res.status(400).json({
        success: false,
        message: 'Booking already paid'
      });
    }

    const transactionId = `TXN-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

    booking.paymentStatus = 'PAID';
    booking.status = 'CONFIRMED';
    booking.paymentMethod = paymentMethod;
    await booking.save();

    const commissionRate = 0.15;
    const commissionAmount = booking.totalAmount * commissionRate;
    const earningAmount = booking.totalAmount - commissionAmount;

    await Transaction.create({
      agentId: booking.agentId._id,
      bookingId: booking._id,
      packageId: booking.packageId._id,
      userId: booking.userId,
      type: 'EARNING',
      amount: earningAmount,
      commissionRate: commissionRate * 100,
      commissionAmount: commissionAmount,
      payoutStatus: 'PENDING',
      paymentMethod,
      paymentDetails: {
        transactionId,
        ...paymentDetails
      }
    });

    await Agent.findByIdAndUpdate(booking.agentId._id, {
      $inc: { totalBookings: 1 }
    });

    res.json({
      success: true,
      message: 'Payment processed successfully',
      booking,
      transaction: {
        id: transactionId,
        amount: booking.totalAmount,
        earning: earningAmount,
        commission: commissionAmount
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

exports.verifyPayment = async (req, res) => {
  try {
    const { transactionId } = req.params;

    const transaction = await Transaction.findOne({
      'paymentDetails.transactionId': transactionId
    })
      .populate('bookingId')
      .populate('packageId')
      .populate('userId', 'fullName email');

    if (!transaction) {
      return res.status(404).json({
        success: false,
        message: 'Transaction not found'
      });
    }

    res.json({
      success: true,
      verified: true,
      transaction
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

exports.getPaymentMethods = async (req, res) => {
  try {
    const paymentMethods = [
      {
        id: 'jazzcash',
        name: 'JazzCash',
        icon: 'mobile',
        supported: true
      }
    ];

    res.json({
      success: true,
      paymentMethods,
      // Compatibility for legacy frontend readers.
      methods: paymentMethods.map((method) => method.id.toUpperCase())
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

exports.processRefund = async (req, res) => {
  try {
    const { bookingId, reason } = req.body;

    const booking = await Booking.findById(bookingId)
      .populate('packageId')
      .populate('agentId');

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    if (booking.paymentStatus !== 'PAID') {
      return res.status(400).json({
        success: false,
        message: 'Cannot refund unpaid booking'
      });
    }

    if (booking.refundStatus !== 'APPROVED') {
      return res.status(400).json({
        success: false,
        message: 'Refund not approved yet'
      });
    }

    const refundTransactionId = `REF-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

    await Transaction.create({
      agentId: booking.agentId._id,
      bookingId: booking._id,
      packageId: booking.packageId._id,
      userId: booking.userId,
      type: 'REFUND',
      amount: booking.totalAmount,
      commissionRate: 0,
      commissionAmount: 0,
      payoutStatus: 'PAID',
      paymentMethod: booking.paymentMethod,
      paymentDetails: {
        transactionId: refundTransactionId
      },
      notes: reason
    });

    const originalTransaction = await Transaction.findOne({
      bookingId: booking._id,
      type: 'EARNING'
    });

    if (originalTransaction) {
      originalTransaction.payoutStatus = 'FAILED';
      originalTransaction.notes = 'Refunded to user';
      await originalTransaction.save();
    }

    booking.paymentStatus = 'REFUNDED';
    booking.status = 'CANCELLED';
    await booking.save();

    await Package.findByIdAndUpdate(booking.packageId._id, {
      $inc: { availableSeats: booking.seats }
    });

    res.json({
      success: true,
      message: 'Refund processed successfully',
      refundId: refundTransactionId,
      refundAmount: booking.totalAmount
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

exports.getTransactionHistory = async (req, res) => {
  try {
    const { type, status, limit = 20, skip = 0 } = req.query;
    const userId = req.user.id;

    const query = { userId };
    if (type) query.type = type;
    if (status) query.payoutStatus = status;

    const transactions = await Transaction.find(query)
      .populate('packageId', 'title location price')
      .populate('bookingId', 'status travelDate')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(skip));

    const total = await Transaction.countDocuments(query);

    res.json({
      success: true,
      transactions,
      // Compatibility for legacy frontend readers.
      payments: transactions,
      pagination: {
        total,
        limit: parseInt(limit),
        skip: parseInt(skip),
        hasMore: total > parseInt(skip) + parseInt(limit)
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
