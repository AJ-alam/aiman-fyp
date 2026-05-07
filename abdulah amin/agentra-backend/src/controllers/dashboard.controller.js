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
  try {
    const totalUsers = await User.countDocuments();
    const totalAgents = await Agent.countDocuments();
    
    // New Agents (Current Month)
    const startOfMonth = new Date();
    startOfMonth.setDate(1);
    startOfMonth.setHours(0, 0, 0, 0);
    const newAgents = await Agent.countDocuments({ createdAt: { $gte: startOfMonth } });

    const pendingAgents = await Agent.countDocuments({ status: 'PENDING_APPROVAL' });
    const approvedAgents = await Agent.countDocuments({ status: 'APPROVED' });
    const rejectedAgents = await Agent.countDocuments({ status: 'REJECTED' });
    
    const totalBookings = await Booking.countDocuments();
    
    // Pending Refunds
    const pendingRefunds = await Booking.countDocuments({ refundStatus: 'REQUESTED' });
    
    const totalComplaints = await Complaint.countDocuments();

    res.json({
      success: true,
      totalUsers,
      totalAgents,
      newAgents,
      pendingAgents,
      approvedAgents,
      rejectedAgents,
      totalBookings,
      pendingRefunds,
      totalComplaints
    });
  } catch (error) {
    console.error('❌ Error in ownerDashboard:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
};
