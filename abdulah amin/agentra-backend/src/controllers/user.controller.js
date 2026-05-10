const Booking = require('../models/Booking');
const Review = require('../models/Review');
const Complaint = require('../models/Complaint');
const Package = require('../models/Package');
const User = require('../models/User');
const Agent = require('../models/Agent');

// ================= PROFILE =================
exports.getProfile = async (req, res) => {
  const user = await User.findById(req.user.id).select('-password');
  res.json({ success: true, user });
};

exports.updateProfile = async (req, res) => {
  const updated = await User.findByIdAndUpdate(req.user.id, req.body, { new: true });
  res.json({ success: true, user: updated });
};

// ================= BOOKINGS =================
exports.createBooking = async (req, res) => {
  try {
    const { packageId, seats, travelDate, paymentMethod = 'CARD' } = req.body;

    if (!packageId || !seats || !travelDate) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: packageId, seats, and travelDate are required',
      });
    }

    if (seats <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Seats must be a positive number',
      });
    }

    const pkg = await Package.findById(packageId);
    if (!pkg) return res.status(404).json({ success: false, message: "Package not found" });

    if (pkg.availableSeats < seats)
      return res.status(400).json({ success: false, message: "Not enough seats available" });

    const totalAmount = seats * pkg.price;

    const booking = await Booking.create({
      userId: req.user.id,
      agentId: pkg.agentId,
      packageId,
      seats,
      totalAmount,
      travelDate,
      paymentMethod,
      paymentStatus: 'PAID',
    });

    await Package.findByIdAndUpdate(packageId, { $inc: { availableSeats: -seats } });
    await User.findByIdAndUpdate(req.user.id, { $inc: { totalBookings: 1 } });

    res.status(201).json({ success: true, booking });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.getUserBookings = async (req, res) => {
  const bookings = await Booking.find({ userId: req.user.id }).populate('packageId');
  res.json({ success: true, bookings });
};

// ================= REVIEWS =================
exports.createReview = async (req, res) => {
  const { packageId, rating, comment } = req.body;

  const pkg = await Package.findById(packageId);
  if (!pkg) return res.status(404).json({ message: "Package not found" });

  const review = await Review.create({
    userId: req.user.id,
    agentId: pkg.agentId,
    packageId,
    rating,
    comment
  });

  const reviews = await Review.find({ agentId: pkg.agentId });
  const avg = reviews.reduce((a, b) => a + b.rating, 0) / reviews.length;

  await Agent.findByIdAndUpdate(pkg.agentId, { averageRating: avg });

  res.status(201).json({ success: true, review });
};

exports.getUserReviews = async (req, res) => {
  const { packageId } = req.query;

  // Compatibility: frontend calls /users/reviews?packageId=... publicly.
  if (packageId) {
    const reviews = await Review.find({ packageId })
      .populate('userId', 'fullName profileImage')
      .populate('packageId');
    return res.json({ success: true, reviews });
  }

  if (!req.user?.id) {
    return res.status(401).json({ success: false, message: 'Unauthorized' });
  }

  const reviews = await Review.find({ userId: req.user.id }).populate('packageId');
  return res.json({ success: true, reviews });
};

// ================= COMPLAINTS =================
exports.raiseComplaint = async (req, res) => {
  try {
    const { bookingId, subject, description } = req.body;

    // Derive agentId from the booking so complaint is routed to the correct agent
    let agentId;
    if (bookingId) {
      const booking = await Booking.findById(bookingId);
      if (booking) agentId = booking.agentId;
    }

    const complaint = await Complaint.create({
      userId: req.user.id,
      agentId,
      bookingId,
      subject,
      description
    });

    res.status(201).json({ success: true, complaint });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.getUserComplaints = async (req, res) => {
  try {
    const complaints = await Complaint.find({ userId: req.user.id })
      .sort({ createdAt: -1 });
    res.json({ success: true, complaints });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ================= AI PREFERENCES =================
exports.updatePreferences = async (req, res) => {
  const updated = await User.findByIdAndUpdate(
    req.user.id,
    { preferences: req.body },
    { new: true }
  );
  res.json({ success: true, preferences: updated.preferences });
};

// ================= ACCOUNT =================
exports.deactivateAccount = async (req, res) => {
  await User.findByIdAndUpdate(req.user.id, { isActive: false });
  res.json({ success: true, message: "Account deactivated" });
};
