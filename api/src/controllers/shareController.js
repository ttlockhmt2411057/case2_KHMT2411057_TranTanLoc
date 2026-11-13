const Task = require('../models/Task');
const User = require('../models/User');
const TaskShare = require('../models/TaskShare');

// 1. Chia sẻ / Giao việc cho người dùng qua Email
exports.shareTask = async (req, res) => {
  try {
    const { taskId } = req.params;
    const { email, permission } = req.body;
    const currentUserId = req.user.id;

    const task = await Task.findById(taskId);
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });

    // Chỉ người tạo công việc mới có quyền chia sẻ
    if (task.createdBy.toString() !== currentUserId) {
      return res.status(403).json({ message: 'Bạn không có quyền chia sẻ công việc này' });
    }

    const targetUser = await User.findOne({ email: email.trim().toLowerCase() });
    if (!targetUser) {
      return res.status(404).json({ message: 'Không tìm thấy tài khoản với email này' });
    }

    if (targetUser._id.toString() === currentUserId) {
      return res.status(400).json({ message: 'Không thể tự chia sẻ công việc cho chính mình' });
    }

    // Nếu đã chia sẻ rồi thì cập nhật quyền, chưa thì tạo mới
    const share = await TaskShare.findOneAndUpdate(
      { taskId, sharedWithUserId: targetUser._id },
      {
        sharedByUserId: currentUserId,
        permission: permission === 'edit' ? 'edit' : 'view',
      },
      { new: true, upsert: true }
    ).populate('sharedWithUserId', 'fullName email');

    res.status(200).json({
      message: 'Chia sẻ công việc thành công',
      share,
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server khi chia sẻ công việc', error: error.message });
  }
};

// 2. Lấy danh sách những người được chia sẻ của một công việc
exports.getTaskShares = async (req, res) => {
  try {
    const { taskId } = req.params;
    const shares = await TaskShare.find({ taskId })
      .populate('sharedWithUserId', 'fullName email')
      .sort({ createdAt: -1 });

    res.status(200).json(shares);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi lấy danh sách chia sẻ', error: error.message });
  }
};

// 3. Thu hồi quyền chia sẻ (Gỡ người dùng khỏi công việc)
exports.removeTaskShare = async (req, res) => {
  try {
    const { taskId, shareId } = req.params;
    const currentUserId = req.user.id;

    const task = await Task.findById(taskId);
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });

    if (task.createdBy.toString() !== currentUserId) {
      return res.status(403).json({ message: 'Bạn không có quyền gỡ thành viên khỏi công việc này' });
    }

    await TaskShare.findByIdAndDelete(shareId);
    res.status(200).json({ message: 'Đã thu hồi quyền chia sẻ' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi gỡ chia sẻ', error: error.message });
  }
};