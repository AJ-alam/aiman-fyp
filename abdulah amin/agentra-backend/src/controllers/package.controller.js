const Package = require('../models/Package');
const Agent = require('../models/Agent');

// ================= PUBLIC =================
exports.getPublicPackages = async (req, res) => {
  try {
    const packages = await Package.find({ isActive: true })
      .populate('agentId', 'fullName businessName');
    res.json({ success: true, packages });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.getLocations = async (req, res) => {
  try {
    const locations = await Package.distinct('location', { isActive: true });
    res.json({ success: true, locations });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.getPackageDetails = async (req, res) => {
  try {
    const pkg = await Package.findById(req.params.id)
      .populate('agentId', 'fullName businessName');

    if (!pkg || !pkg.isActive)
      return res.status(404).json({ success: false, message: 'Package not available' });

    res.json({ success: true, package: pkg });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ================= AGENT =================
exports.createPackage = async (req, res) => {
  try {
    const pkg = await Package.create({ ...req.body, agentId: req.user.id });
    await Agent.findByIdAndUpdate(req.user.id, { $inc: { totalPackages: 1 } });

    res.status(201).json({ success: true, package: pkg });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.getAgentPackages = async (req, res) => {
  try {
    const packages = await Package.find({ agentId: req.user.id });
    res.json({ success: true, packages });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.updatePackage = async (req, res) => {
  try {
    const updated = await Package.findOneAndUpdate(
      { _id: req.params.id, agentId: req.user.id },
      req.body,
      { new: true }
    );

    if (!updated)
      return res.status(404).json({ success: false, message: 'Not found or unauthorized' });

    res.json({ success: true, package: updated });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.deletePackage = async (req, res) => {
  try {
    const deleted = await Package.findOneAndDelete({ _id: req.params.id, agentId: req.user.id });

    if (!deleted)
      return res.status(404).json({ success: false, message: 'Not found or unauthorized' });

    await Agent.findByIdAndUpdate(req.user.id, { $inc: { totalPackages: -1 } });

    res.json({ success: true, message: 'Package deleted' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ================= OWNER =================
exports.getAllPackages = async (req, res) => {
  try {
    const packages = await Package.find();
    res.json({ success: true, packages });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.togglePackageStatus = async (req, res) => {
  try {
    const pkg = await Package.findById(req.params.id);

    if (!pkg)
      return res.status(404).json({ success: false, message: 'Package not found' });

    pkg.isActive = !pkg.isActive;
    await pkg.save();

    res.json({ success: true, status: pkg.isActive });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.cleanupPackages = async (req, res) => {
  try {
    const packages = await Package.find({ title: { $regex: 'Dream Vacation', $options: 'i' } });

    // Safety check: ensure we found some packages
    if (packages.length === 0) {
      return res.json({ success: true, message: 'No matching packages found to delete.' });
    }

    // Delete the first 2 found packages
    const toDelete = packages.slice(0, 2);

    for (const pkg of toDelete) {
      await Package.findByIdAndDelete(pkg._id);
    }

    res.json({
      success: true,
      message: `Successfully deleted ${toDelete.length} packages.`,
      deletedPackages: toDelete.map(p => p.title)
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};
