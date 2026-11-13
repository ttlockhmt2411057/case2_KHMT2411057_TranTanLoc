const mongoose = require('mongoose');

const taskShareSchema = new mongoose.Schema(
  {
    taskId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Task',
      required: true,
    },
    sharedWithUserId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    sharedByUserId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    permission: {
      type: String,
      enum: ['view', 'edit'],
      default: 'view',
    },
  },
  { timestamps: true }
);

// Tránh chia sẻ trùng 1 công việc cho cùng 1 người nhiều lần
taskShareSchema.index({ taskId: 1, sharedWithUserId: 1 }, { unique: true });

module.exports = mongoose.model('TaskShare', taskShareSchema);