const Booking = require('../models/Booking');
const Package = require('../models/Package');
const Agent = require('../models/Agent');
const User = require('../models/User');
const Complaint = require('../models/Complaint');

exports.userDashboard = async (req, res) => {
  const bookings = await Booking.find({ userId: req.user.id }).countDocuments();
  res.json({ success: true, totalBookings: bookings });
};

exports.agentDashboard = async (req, res) => {
  const packages = await Package.find({ agentId: req.user.id }).countDocuments();
  const bookings = await Booking.find({ agentId: req.user.id }).countDocuments();
  res.json({ success: true, packages, bookings });
};

exports.ownerDashboard = async (req, res) => {
  const totalUsers = await User.countDocuments();
  const totalAgents = await Agent.countDocuments();
  const pendingAgents = await Agent.countDocuments({ status: 'PENDING_APPROVAL' });
  const approvedAgents = await Agent.countDocuments({ status: 'APPROVED' });
  const rejectedAgents = await Agent.countDocuments({ status: 'REJECTED' });
  const totalBookings = await Booking.countDocuments();
  const totalComplaints = await Complaint.countDocuments();

  res.json({
    success: true,
    totalUsers,
    totalAgents,
    pendingAgents,
    approvedAgents,
    rejectedAgents,
    totalBookings,
    totalComplaints
  });
};
