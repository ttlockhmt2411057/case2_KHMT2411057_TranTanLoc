const Notification = require('../models/Notification');

exports.createNotification = async ({ userId, taskId, type, title, message }) => {
  return await Notification.create({
    userId,
    taskId,
    type,
    title,
    message,
    isRead: false,
  });
};