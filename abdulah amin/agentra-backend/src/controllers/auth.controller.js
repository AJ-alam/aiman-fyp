const User = require('../models/User');
const Agent = require('../models/Agent');
const Owner = require('../models/Owner');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// ================= TOKEN =================
const generateToken = (id, role) => {
  return jwt.sign({ id, role }, process.env.JWT_SECRET, {
    expiresIn: '7d',
  });
};

// ================= USER =================
const registerUser = async (req, res) => {
  try {
    const { fullName, email, password, phone } = req.body;

    const existing = await User.findOne({ email });
    if (existing) {
      return res.status(400).json({ success: false, message: 'User already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await User.create({
      fullName,
      email,
      phone,
      password: hashedPassword,
    });

    const token = generateToken(user._id, user.role);

    const { password: _, ...userData } = user.toObject();

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      token,
      user: userData,
    });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ================= USER LOGIN =================
const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ success: false, message: 'Invalid credentials' });
    }

    const token = generateToken(user._id, user.role);

    const { password: _, ...userData } = user.toObject();

    res.status(200).json({
      success: true,
      message: 'Login successful',
      token,
      user: userData,
    });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ================= AGENT SIGNUP =================
const registerAgent = async (req, res) => {
  try {
    console.log('🔥 REGISTER AGENT REQUEST BODY:', req.body);
    const { fullName, email, password, phone, businessName, cnic } = req.body;

    const existing = await Agent.findOne({ email });
    if (existing) {
      return res.status(400).json({ success: false, message: 'Agent already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const agent = await Agent.create({
      fullName,
      email,
      phone,
      businessName,
      cnic,
      password: hashedPassword,
      status: 'PENDING_APPROVAL',
    });

    console.log('DATA SAVED:', agent);
    const { password: _, ...agentData } = agent.toObject();

    return res.status(201).json({
      success: true,
      message: 'Your account request has been submitted. Please wait for admin approval (within 24 hours).',
      status: 'PENDING_APPROVAL',
      agent: agentData,
    });

  } catch (err) {
    console.error('❌ REGISTER AGENT ERROR:', err.message, err.stack);
    return res.status(500).json({ success: false, message: err.message });
  }
};

// ================= AGENT LOGIN =================
const loginAgent = async (req, res) => {
  try {
    const { email, password } = req.body;

    const agent = await Agent.findOne({ email });
    if (!agent) {
      return res.status(404).json({ success: false, message: 'Agent not found' });
    }

    const isMatch = await bcrypt.compare(password, agent.password);
    if (!isMatch) {
      return res.status(400).json({ success: false, message: 'Invalid credentials' });
    }

    if (agent.status === 'PENDING_APPROVAL') {
      return res.status(403).json({
        success: false,
        message: 'Your account is not yet approved by admin.',
      });
    }

    if (agent.status === 'REJECTED') {
      return res.status(403).json({
        success: false,
        message: 'Your account has been rejected.',
      });
    }

    const token = generateToken(agent._id, agent.role);

    const { password: _, ...agentData } = agent.toObject();

    res.status(200).json({
      success: true,
      message: 'Login successful',
      token,
      agent: agentData,
    });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ================= OWNER LOGIN =================
const loginOwner = async (req, res) => {
  try {
    const { email, password } = req.body;

    const owner = await Owner.findOne({ email });
    if (!owner) {
      return res.status(404).json({ success: false, message: 'Owner not found' });
    }

    const isMatch = await bcrypt.compare(password, owner.password);
    if (!isMatch) {
      return res.status(400).json({ success: false, message: 'Invalid credentials' });
    }

    const token = generateToken(owner._id, owner.role);

    const { password: _, ...ownerData } = owner.toObject();

    res.status(200).json({
      success: true,
      message: 'Login successful',
      token,
      owner: ownerData,
    });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ================= PROFILE =================
const getAgentProfile = async (req, res) => {
  try {
    const agent = await Agent.findById(req.user.id).select('-password');

    if (!agent) {
      return res.status(404).json({ success: false, message: 'Agent not found' });
    }

    res.status(200).json({ success: true, agent });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ================= UPDATE PROFILE =================
const updateAgentProfile = async (req, res) => {
  try {
    const allowed = [
      'fullName',
      'businessName',
      'phone',
      'location',
      'bio',
      'profileImage',
      'refundPolicy',
      'cancellationPolicy',
    ];

    const updateData = {};

    allowed.forEach((key) => {
      if (req.body[key] !== undefined) {
        updateData[key] = req.body[key];
      }
    });

    const agent = await Agent.findByIdAndUpdate(req.user.id, updateData, {
      new: true,
    }).select('-password');

    if (!agent) {
      return res.status(404).json({ success: false, message: 'Agent not found' });
    }

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      agent,
    });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ================= LOGOUT =================
const logoutUser = async (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Logout successful',
  });
};

// ================= ADMIN =================
const getPendingAgents = async (req, res) => {
  try {
    console.log('🔥 GET PENDING AGENTS REQUEST');
    const agents = await Agent.find({ status: 'PENDING_APPROVAL' })
      .select('-password')
      .sort({ createdAt: -1 });

    console.log(`✅ Found ${agents.length} pending agents`);
    res.status(200).json({
      success: true,
      count: agents.length,
      agents,
    });

  } catch (err) {
    console.error('❌ GET PENDING AGENTS ERROR:', err.message);
    res.status(500).json({ success: false, message: err.message });
  }
};

const getAllAgents = async (req, res) => {
  try {
    const agents = await Agent.find({})
      .select('-password')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: agents.length,
      agents,
    });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const approveAgent = async (req, res) => {
  try {
    console.log('🔥 APPROVE AGENT REQUEST:', req.params.agentId);
    console.log('🔥 REQUEST BODY:', req.body);

    const agent = await Agent.findById(req.params.agentId);

    if (!agent) {
      return res.status(404).json({ success: false, message: 'Agent not found' });
    }

    if (agent.status !== 'PENDING_APPROVAL') {
      return res.status(400).json({ success: false, message: 'Not in pending state' });
    }

    agent.status = 'APPROVED';
    agent.isVerified = true;
    agent.emailVerified = true;
    await agent.save();

    console.log('DATA SAVED:', agent);
    const { password: _, ...data } = agent.toObject();

    res.status(200).json({
      success: true,
      message: 'Agent approved',
      agent: data,
    });

  } catch (err) {
    console.error('❌ APPROVE AGENT ERROR:', err.message);
    res.status(500).json({ success: false, message: err.message });
  }
};

const rejectAgent = async (req, res) => {
  try {
    console.log('🔥 REJECT AGENT REQUEST:', req.params.agentId);
    console.log('🔥 REQUEST BODY:', req.body);
    const { reason } = req.body;

    const agent = await Agent.findById(req.params.agentId);

    if (!agent) {
      return res.status(404).json({ success: false, message: 'Agent not found' });
    }

    if (agent.status !== 'PENDING_APPROVAL') {
      return res.status(400).json({ success: false, message: 'Not in pending state' });
    }

    agent.status = 'REJECTED';
    agent.rejectionReason = reason || '';
    await agent.save();

    console.log('DATA SAVED:', agent);
    const { password: _, ...data } = agent.toObject();

    res.status(200).json({
      success: true,
      message: 'Agent rejected',
      agent: data,
    });

  } catch (err) {
    console.error('❌ REJECT AGENT ERROR:', err.message);
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = {
  registerUser,
  loginUser,
  registerAgent,
  loginAgent,
  loginOwner,
  getAgentProfile,
  updateAgentProfile,
  logoutUser,
  getPendingAgents,
  approveAgent,
  rejectAgent,
};