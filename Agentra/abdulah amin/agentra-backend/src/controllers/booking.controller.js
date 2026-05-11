const Booking = require('../models/Booking');
const Package = require('../models/Package');
const User = require('../models/User');

// ---------- CREATE ----------
exports.createBooking = async (req, res) => {
  try {
    const { packageId, seats, travelDate, paymentMethod } = req.body;

    // Validate required fields
    if (!packageId || !seats || !travelDate || !paymentMethod) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: packageId, seats, travelDate, and paymentMethod are required'
      });
    }

    // Validate seats is a positive number
    if (seats <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Seats must be a positive number'
      });
    }

    const pkg = await Package.findById(packageId);
    if (!pkg) {
      return res.status(404).json({
        success: false,
        message: 'Package not found'
      });
    }

    if (pkg.availableSeats < seats) {
      return res.status(400).json({
        success: false,
        message: `Not enough seats available. Only ${pkg.availableSeats} seats remaining.`
      });
    }

    const totalAmount = pkg.price * seats;

    const booking = await Booking.create({
      userId: req.user.id,
      agentId: pkg.agentId,
      packageId,
      seats,
      travelDate,
      totalAmount,
      paymentMethod,
      paymentStatus: 'PAID'
    });

    await Package.findByIdAndUpdate(packageId, { $inc: { availableSeats: -seats } });
    await User.findByIdAndUpdate(req.user.id, { $inc: { totalBookings: 1, rewardPoints: 10 } });

    res.status(201).json({ success: true, booking });
  } catch (error) {
    console.error('🔴 Create booking error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create booking. Please try again.',
      error: error.message
    });
  }
};

// ---------- USER BOOKINGS ----------
exports.getUserBookings = async (req, res) => {
  const bookings = await Booking.find({ userId: req.user.id }).populate('packageId');
  res.json({ success: true, bookings });
};

// ---------- CANCEL ----------
exports.cancelBooking = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }

    if (booking.userId.toString() !== req.user.id.toString()) {
      return res.status(403).json({ success: false, message: 'Unauthorized' });
    }

    booking.status = 'CANCELLED';
    booking.refundStatus = 'REQUESTED';
    await booking.save();

    return res.json({ success: true, message: 'Booking cancelled. Refund initiated.' });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Failed to cancel booking',
      error: error.message,
    });
  }
};

// ---------- AGENT BOOKINGS ----------
exports.getAgentBookings = async (req, res) => {
  try {
    // Exclude completed bookings and bookings whose travel date has already passed
    const bookings = await Booking.find({
      agentId: req.user.id,
      status: { $ne: 'COMPLETED' },
      travelDate: { $gte: new Date() }
    }).populate('userId packageId').sort({ createdAt: -1 });
    res.json({ success: true, bookings });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// ---------- OWNER BOOKINGS ----------
exports.getAllBookings = async (req, res) => {
  const bookings = await Booking.find().populate('userId agentId packageId');
  res.json({ success: true, bookings });
};
