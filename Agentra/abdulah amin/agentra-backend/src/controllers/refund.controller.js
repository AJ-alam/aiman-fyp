const Booking = require('../models/Booking');
const Complaint = require('../models/Complaint');
const Package = require('../models/Package');
const Transaction = require('../models/Transaction');
const User = require('../models/User');
const Agent = require('../models/Agent');
const mongoose = require('mongoose');

exports.requestRefund = async (req, res) => {
  try {
    const { bookingId, reason } = req.body;
    const userId = req.user.id;

    const booking = await Booking.findById(bookingId);

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

    if (booking.paymentStatus !== 'PAID') {
      return res.status(400).json({
        success: false,
        message: 'Cannot refund unpaid booking'
      });
    }

    if (booking.refundStatus !== 'NONE') {
      return res.status(400).json({
        success: false,
        message: 'Refund already requested or processed'
      });
    }

    booking.status = 'CANCELLED';
    booking.refundStatus = 'REQUESTED';
    booking.cancellationReason = reason;
    await booking.save();

    await Complaint.create({
      userId,
      agentId: booking.agentId,
      bookingId: booking._id,
      subject: 'Refund Request',
      description: `Refund request for booking: ${reason}`,
      status: 'OPEN'
    });

    res.json({
      success: true,
      message: 'Refund request submitted successfully',
      booking
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

exports.getRefundRequests = async (req, res) => {
  try {
    const agentId = req.user.id;
    const { status } = req.query;

    let query = { agentId, refundStatus: 'REQUESTED' };
    if (status) {
      query.refundStatus = status;
    }

    const bookings = await Booking.find(query)
      .populate('userId', 'fullName email phone')
      .populate('packageId', 'title location price')
      .populate('agentId', 'fullName businessName')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      refundRequests: bookings,
      total: bookings.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

exports.approveRefund = async (req, res) => {
  try {
    const { bookingId } = req.params;
    const { reason } = req.body;
    const agentId = req.user.id;

    const booking = await Booking.findById(bookingId)
      .populate('packageId')
      .populate('agentId');

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    if (booking.agentId._id.toString() !== agentId.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    if (booking.refundStatus !== 'REQUESTED') {
      return res.status(400).json({
        success: false,
        message: 'Refund not requested'
      });
    }

    booking.refundStatus = 'APPROVED';
    await booking.save();

    const complaint = await Complaint.findOne({
      bookingId: booking._id,
      subject: 'Refund Request'
    });

    if (complaint) {
      complaint.status = 'RESOLVED';
      complaint.ownerResponse = `Refund approved: ${reason || 'No specific reason provided'}`;
      await complaint.save();
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
      payoutStatus: 'PENDING',
      paymentMethod: booking.paymentMethod,
      paymentDetails: {
        transactionId: refundTransactionId
      },
      notes: reason || 'Refund approved by agent'
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

    await Agent.findByIdAndUpdate(booking.agentId._id, {
      $inc: { totalBookings: -1 }
    });

    res.json({
      success: true,
      message: 'Refund approved successfully',
      booking,
      refundId: refundTransactionId
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

exports.rejectRefund = async (req, res) => {
  try {
    const { bookingId } = req.params;
    const { reason } = req.body;
    const agentId = req.user.id;

    const booking = await Booking.findById(bookingId);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    if (booking.agentId.toString() !== agentId.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    if (booking.refundStatus !== 'REQUESTED') {
      return res.status(400).json({
        success: false,
        message: 'Refund not requested'
      });
    }

    booking.refundStatus = 'REJECTED';
    booking.status = 'CONFIRMED';
    await booking.save();

    const complaint = await Complaint.findOne({
      bookingId: booking._id,
      subject: 'Refund Request'
    });

    if (complaint) {
      complaint.status = 'RESOLVED';
      complaint.ownerResponse = `Refund rejected: ${reason || 'No specific reason provided'}`;
      await complaint.save();
    }

    res.json({
      success: true,
      message: 'Refund rejected successfully',
      booking
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

exports.getMyRefundRequests = async (req, res) => {
  try {
    const userId = req.user.id;
    const { status } = req.query;

    // Only show cancelled bookings with a refund status
    let query = {
      userId,
      status: 'CANCELLED',
      refundStatus: { $ne: 'NONE' }
    };
    if (status) {
      query.refundStatus = status;
    }

    const bookings = await Booking.find(query)
      .populate('packageId', 'title location price images image')
      .populate('agentId', 'fullName businessName')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      refundRequests: bookings,
      total: bookings.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

exports.getAllRefundRequests = async (req, res) => {
  try {
    const { status, limit = 50, skip = 0 } = req.query;

    let query = { refundStatus: { $ne: 'NONE' } };
    if (status) {
      query.refundStatus = status;
    }

    const bookings = await Booking.find(query)
      .populate('userId', 'fullName email phone')
      .populate('packageId', 'title location price')
      .populate('agentId', 'fullName businessName')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(skip));

    const total = await Booking.countDocuments(query);

    res.json({
      success: true,
      refundRequests: bookings,
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

exports.getRefundStats = async (req, res) => {
  try {
    const agentId = req.user.id;
    const agentObjectId = new mongoose.Types.ObjectId(agentId);

    const stats = await Booking.aggregate([
      {
        $match: {
          agentId: agentObjectId,
          refundStatus: { $ne: 'NONE' }
        }
      },
      {
        $group: {
          _id: '$refundStatus',
          count: { $sum: 1 },
          totalAmount: { $sum: '$totalAmount' }
        }
      }
    ]);

    const summary = {
      REQUESTED: 0,
      APPROVED: 0,
      REJECTED: 0
    };

    stats.forEach(stat => {
      summary[stat._id] = {
        count: stat.count,
        totalAmount: stat.totalAmount
      };
    });

    const totalRequested = stats
      .filter(s => s._id === 'REQUESTED')
      .reduce((sum, s) => sum + s.totalAmount, 0);

    const totalApproved = stats
      .filter(s => s._id === 'APPROVED')
      .reduce((sum, s) => sum + s.totalAmount, 0);

    res.json({
      success: true,
      stats: summary,
      overview: {
        totalRefunded: totalApproved,
        pendingRefunds: totalRequested
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
