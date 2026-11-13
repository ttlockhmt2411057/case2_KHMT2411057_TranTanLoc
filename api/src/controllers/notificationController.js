const Notification = require('../models/Notification');

exports.getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ userId: req.user.id })
      .sort({ createdAt: -1 })
      .limit(50);
    res.status(200).json(notifications);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi tải thông báo', error: error.message });
  }
};

exports.getUnreadCount = async (req, res) => {
  try {
    const count = await Notification.countDocuments({ userId: req.user.id, isRead: false });
    res.status(200).json({ unreadCount: count });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi đếm thông báo chưa đọc', error: error.message });
  }
};

exports.markAsRead = async (req, res) => {
  try {
    await Notification.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.id },
      { isRead: true }
    );
    res.status(200).json({ message: 'Đã đánh dấu đã đọc' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi cập nhật thông báo', error: error.message });
  }
};

exports.markAllAsRead = async (req, res) => {
  try {
    await Notification.updateMany({ userId: req.user.id, isRead: false }, { isRead: true });
    res.status(200).json({ message: 'Đã đánh dấu tất cả đã đọc' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi cập nhật tất cả thông báo', error: error.message });
  }
};