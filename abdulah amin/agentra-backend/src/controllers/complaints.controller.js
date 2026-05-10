const Complaint = require('../models/Complaint');

exports.getAllComplaints = async (req, res) => {
  try {
    console.log("📋 [ADMIN] Fetching all complaints...");
    const complaints = await Complaint.find()
      .populate('userId', 'fullName email role')
      .populate('agentId', 'fullName email businessName')
      .populate('bookingId')
      .sort({ createdAt: -1 });

    console.log(`✅ [ADMIN] Found ${complaints.length} complaints`);
    res.json({
      success: true,
      complaints,
      message: "Complaints retrieved successfully"
    });
  } catch (error) {
    console.error("❌ [ADMIN] Error fetching complaints:", error.message);
    res.status(500).json({
      success: false,
      message: "Failed to fetch complaints",
      error: error.message
    });
  }
};

exports.updateComplaintStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, ownerResponse } = req.body;

    console.log(`🔄 [ADMIN] Updating complaint: ${id} to status: ${status}`);

    const complaint = await Complaint.findById(id);

    if (!complaint) {
      console.warn(`⚠️ [ADMIN] Complaint not found: ${id}`);
      return res.status(404).json({
        success: false,
        message: "Complaint not found"
      });
    }

    complaint.status = status;
    if (ownerResponse) {
      complaint.ownerResponse = ownerResponse;
    }

    await complaint.save();

    console.log(`✅ [ADMIN] Complaint updated successfully: ${complaint._id}`);
    res.json({
      success: true,
      complaint,
      message: "Complaint updated successfully"
    });
  } catch (error) {
    console.error("❌ [ADMIN] Error updating complaint:", error.message);
    res.status(500).json({
      success: false,
      message: "Failed to update complaint",
      error: error.message
    });
  }
};