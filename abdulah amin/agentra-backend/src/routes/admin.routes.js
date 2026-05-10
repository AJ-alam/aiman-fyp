const express = require("express");
const router = express.Router();

const Agent = require("../models/Agent");
const protect = require("../middleware/auth.middleware");
const role = require("../middleware/role.middleware");

// =============== GET ALL AGENTS ===============
router.get("/agents", protect, role("OWNER"), async (req, res) => {
  try {
    console.log("📋 [ADMIN] Fetching all agents...");
    const agents = await Agent.find().select("-password");
    
    console.log(`✅ [ADMIN] Found ${agents.length} agents`);
    res.json({
      success: true,
      agents,
      message: "Agents retrieved successfully"
    });
  } catch (error) {
    console.error("❌ [ADMIN] Error fetching agents:", error.message);
    res.status(500).json({
      success: false,
      message: "Failed to fetch agents",
      error: error.message
    });
  }
});

// =============== APPROVE AGENT ===============
router.patch("/approve-agent/:id", protect, role("OWNER"), async (req, res) => {
  try {
    console.log(`🔄 [ADMIN] Approving agent: ${req.params.id}`);
    
    const agent = await Agent.findByIdAndUpdate(
      req.params.id,
      { 
        status: "APPROVED",
        isVerified: true,
        emailVerified: true 
      },
      { new: true }
    );

    if (!agent) {
      console.log(`❌ [ADMIN] Agent not found during approval: ${req.params.id}`);
      return res.status(404).json({
        success: false,
        message: "Agent not found"
      });
    }

    console.log(`✅ [ADMIN] Agent approved successfully: ${agent._id} | Status: ${agent.status}`);

    res.json({
      success: true,
      message: "Agent approved successfully",
      agent: {
        _id: agent._id,
        email: agent.email,
        name: agent.fullName || agent.name,
        status: agent.status
      }
    });
  } catch (error) {
    console.error("❌ [ADMIN] Error approving agent:", error.message);
    res.status(500).json({
      success: false,
      message: "Internal server error during approval",
      error: error.message
    });
  }
});

// @route   PATCH /api/admin/reject-agent/:id
// @desc    Reject an agent request
router.patch("/reject-agent/:id", protect, role("OWNER"), async (req, res) => {
  try {
    const { reason } = req.body;
    console.log(`🔄 [ADMIN] Rejecting agent: ${req.params.id}. Reason: ${reason}`);

    const agent = await Agent.findByIdAndUpdate(
      req.params.id,
      { 
        status: "REJECTED",
        rejectionReason: reason || "No reason provided"
      },
      { new: true }
    );

    if (!agent) {
      return res.status(404).json({
        success: false,
        message: "Agent not found"
      });
    }

    res.json({
      success: true,
      message: "Agent rejected successfully",
      agent: {
        _id: agent._id,
        status: agent.status
      }
    });
  } catch (error) {
    console.error("❌ [ADMIN] Error rejecting agent:", error.message);
    res.status(500).json({
      success: false,
      message: "Internal server error during rejection"
    });
  }
});

// ================= COMPLAINTS =================
router.get("/complaints", protect, role("OWNER"), async (req, res) => {
  try {
    const Complaint = require("../models/Complaint");
    const complaints = await Complaint.find().sort({ createdAt: -1 });
    res.json({ success: true, complaints });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.patch("/complaints/:id/respond", protect, role("OWNER"), async (req, res) => {
  try {
    const Complaint = require("../models/Complaint");
    const { response } = req.body;
    const complaint = await Complaint.findById(req.params.id);
    if (!complaint) return res.status(404).json({ success: false, message: "Complaint not found" });

    complaint.ownerResponse = response;
    complaint.adminResponse = response; // keep both in sync
    complaint.status = "RESOLVED";
    await complaint.save();

    res.json({ success: true, complaint });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;