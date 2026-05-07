const mongoose = require('mongoose');

const complaintSchema = new mongoose.Schema({

  // ---------- Relations ----------
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },

  agentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Agent'
  },

  bookingId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Booking'
  },

  // ---------- Complaint Content ----------
  subject: {
    type: String,
    required: true
  },

  description: {
    type: String,
    required: true
  },

  // ---------- Workflow ----------
  status: {
    type: String,
    enum: ['OPEN', 'IN_PROGRESS', 'RESOLVED'],
    default: 'OPEN'
  },

  // ---------- Owner Handling ----------
  ownerResponse: {
    type: String,
    default: ''
  }

}, { timestamps: true });

module.exports = mongoose.model('Complaint', complaintSchema);
