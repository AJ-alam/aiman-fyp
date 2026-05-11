const Agent = require('../models/Agent');
const Complaint = require('../models/Complaint');
const Booking = require('../models/Booking');
const User = require('../models/User');

// ---------- GET ALL AGENTS ----------
exports.getAgents = async (req, res) => {
  const agents = await Agent.find().select('-password');
  res.json({ success: true, agents });
};

// ---------- VERIFY AGENT ----------
exports.verifyAgent = async (req, res) => {
  await Agent.findByIdAndUpdate(req.params.id, { isVerified: true });
  res.json({ success: true, message: 'Agent verified successfully' });
};

// ---------- BLOCK AGENT ----------
exports.blockAgent = async (req, res) => {
  await Agent.findByIdAndUpdate(req.params.id, { 
    status: 'BLOCKED',
    isVerified: false 
  });
  res.json({ success: true, message: 'Agent blocked successfully' });
};

// ---------- UNBLOCK AGENT ----------
exports.unblockAgent = async (req, res) => {
  await Agent.findByIdAndUpdate(req.params.id, { 
    status: 'APPROVED',
    isVerified: true 
  });
  res.json({ success: true, message: 'Agent unblocked successfully' });
};

// ---------- REJECT AGENT ----------
exports.rejectAgent = async (req, res) => {
  try {
    const agent = await Agent.findById(req.params.id);
    if (!agent) {
      return res.status(404).json({ success: false, message: 'Agent not found' });
    }

    // Delete the agent from the database
    await Agent.findByIdAndDelete(req.params.id);

    res.json({ success: true, message: 'Agent application rejected and removed' });
  } catch (error) {
    console.error('Reject agent error:', error);
    res.status(500).json({ success: false, message: 'Failed to reject agent' });
  }
};

// ---------- GET COMPLAINTS ----------
exports.getComplaints = async (req, res) => {
  const complaints = await Complaint.find()
    .populate('userId')
    .populate('bookingId');
  res.json({ success: true, complaints });
};

// ---------- RESPOND COMPLAINT ----------
exports.respondComplaint = async (req, res) => {
  const { response, status } = req.body;

  await Complaint.findByIdAndUpdate(req.params.id, {
    adminResponse: response,
    status
  });

  res.json({ success: true, message: 'Complaint updated successfully' });
};

// ---------- DASHBOARD STATS ----------
exports.getDashboardStats = async (req, res) => {
  const totalUsers = await User.countDocuments();
  const totalAgents = await Agent.countDocuments();
  const totalBookings = await Booking.countDocuments();
  const totalComplaints = await Complaint.countDocuments();

  res.json({
    success: true,
    stats: {
      totalUsers,
      totalAgents,
      totalBookings,
      totalComplaints
    }
  });
};
