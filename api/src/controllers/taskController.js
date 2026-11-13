const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');

// Lấy danh sách công việc (Tất cả / Tôi tạo / Được giao)
exports.getTasks = async (req, res) => {
  try {
    const userId = req.user.id;
    const { scope, status, priority, q, sortBy = 'createdAt', order = 'desc' } = req.query;

    // Tìm các taskId mà user hiện tại được chia sẻ
    const sharedRecords = await TaskShare.find({ sharedWithUserId: userId }).select('taskId');
    const sharedTaskIds = sharedRecords.map((item) => item.taskId);

    let filter = {};
    if (scope === 'created') {
      filter.createdBy = userId;
    } else if (scope === 'assigned') {
      filter._id = { $in: sharedTaskIds };
    } else {
      // Mặc định lấy cả việc tôi tạo VÀ việc tôi được giao
      filter.$or = [{ createdBy: userId }, { _id: {$in: sharedTaskIds } }];
    }

    if (status) filter.status = status;
    if (priority) filter.priority = priority;
    if (q) filter.title = { $regex: q,$options: 'i' };

    const sortOrder = order === 'asc' ? 1 : -1;
    const tasks = await Task.find(filter)
      .populate('createdBy', 'fullName email')
      .sort({ [sortBy]: sortOrder });

    res.status(200).json(tasks);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi lấy danh sách công việc', error: error.message });
  }
};

// Xem chi tiết công việc (kèm quyền của user hiện tại: owner / edit / view)
exports.getTaskById = async (req, res) => {
  try {
    const userId = req.user.id;
    const task = await Task.findById(req.params.id).populate('createdBy', 'fullName email');
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });

    let userPermission = 'none';
    if (task.createdBy._id.toString() === userId) {
      userPermission = 'owner';
    } else {
      const share = await TaskShare.findOne({ taskId: task._id, sharedWithUserId: userId });
      if (share) userPermission = share.permission;
    }

    if (userPermission === 'none') {
      return res.status(403).json({ message: 'Bạn không có quyền xem công việc này' });
    }

    res.status(200).json({ ...task.toObject(), userPermission });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi lấy chi tiết công việc', error: error.message });
  }
};

// Cập nhật công việc (Chỉ owner hoặc người có quyền edit mới được sửa)
exports.updateTask = async (req, res) => {
  try {
    const userId = req.user.id;
    const task = await Task.findById(req.params.id);
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });

    const isOwner = task.createdBy.toString() === userId;
    const share = await TaskShare.findOne({ taskId: task._id, sharedWithUserId: userId });
    const canEdit = isOwner || (share && share.permission === 'edit');

    if (!canEdit) {
      return res.status(403).json({ message: 'Bạn chỉ có quyền xem, không được chỉnh sửa công việc này' });
    }

    const updatedTask = await Task.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.status(200).json(updatedTask);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi cập nhật công việc', error: error.message });
  }
};