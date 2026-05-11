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

// =============== APPROVE AGENT (Standardized) ===============
router.patch("/travel-agents/:id/approve", protect, role("OWNER"), async (req, res) => {
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
      return res.status(404).json({
        success: false,
        message: "Agent not found"
      });
    }

    res.json({
      success: true,
      message: "Agent Approved",
      agent: {
        _id: agent._id,
        status: agent.status
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Internal server error during approval"
    });
  }
});

// =============== REJECT AGENT (Standardized) ===============
router.patch("/travel-agents/:id/reject", protect, role("OWNER"), async (req, res) => {
  try {
    const { reason } = req.body;
    console.log(`🔄 [ADMIN] Rejecting agent: ${req.params.id}`);

    const agent = await Agent.findByIdAndUpdate(
      req.params.id,
      { 
        status: "REJECTED",
        rejectionReason: reason || "Rejected by Admin"
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
      message: "Agent Rejected",
      agent: {
        _id: agent._id,
        status: agent.status
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Internal server error during rejection"
    });
  }
});

// @route   PATCH /api/admin/approve-agent/:id (LEGACY)
router.patch("/approve-agent/:id", protect, role("OWNER"), async (req, res) => {
  // ... existing logic ...
  // (I'll keep it but I'll actually just call the same logic)
  try {
    const agent = await Agent.findByIdAndUpdate(req.params.id, { status: "APPROVED", isVerified: true }, { new: true });
    if (!agent) return res.status(404).json({ success: false, message: "Agent not found" });
    res.json({ success: true, message: "Agent approved successfully", agent });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// @route   PATCH /api/admin/reject-agent/:id (LEGACY)
router.patch("/reject-agent/:id", protect, role("OWNER"), async (req, res) => {
  try {
    const agent = await Agent.findByIdAndUpdate(req.params.id, { status: "REJECTED" }, { new: true });
    if (!agent) return res.status(404).json({ success: false, message: "Agent not found" });
    res.json({ success: true, message: "Agent rejected successfully", agent });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
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