const Task = require('../models/Task');

exports.getTasks = async (req, res) => {
  try {
    const userId = req.user.id;
    const { scope, status, priority, assigneeId, q, sortBy = 'createdAt', order = 'desc' } = req.query;

    let filter = { $or: [{ createdBy: userId }, { assigneeIds: userId }] };
    if (scope === 'created') filter = { createdBy: userId };
    if (scope === 'assigned') filter = { assigneeIds: userId };
    if (status) filter.status = status;
    if (priority) filter.priority = priority;
    if (assigneeId) filter.assigneeIds = assigneeId;
    if (q) filter.title = { $regex: q, $options: 'i' };

    const sortOrder = order === 'asc' ? 1 : -1;
    const allowedSort = ['dueDate', 'priority', 'createdAt'];
    const sortField = allowedSort.includes(sortBy) ? sortBy : 'createdAt';

    const tasks = await Task.find(filter)
      .populate('createdBy', 'fullName email')
      .populate('assigneeIds', 'fullName email')
      .populate('primaryAssigneeId', 'fullName email')
      .sort({ [sortField]: sortOrder });

    res.json(tasks);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi lấy danh sách công việc', error: err.message });
  }
};

exports.getTaskById = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id)
      .populate('createdBy', 'fullName email')
      .populate('assigneeIds', 'fullName email')
      .populate('primaryAssigneeId', 'fullName email');
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });
    res.json(task);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi lấy chi tiết công việc', error: err.message });
  }
};

exports.createTask = async (req, res) => {
  try {
    const { title, description, startDate, dueDate, priority, status } = req.body;
    if (!title || !dueDate) {
      return res.status(400).json({ message: 'Tên công việc và hạn hoàn thành là bắt buộc' });
    }
    const task = await Task.create({
      title,
      description,
      startDate: startDate || Date.now(),
      dueDate,
      priority: priority || 'medium',
      status: status || 'todo',
      createdBy: req.user.id,
    });
    res.status(201).json(task);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi tạo công việc', error: err.message });
  }
};

exports.updateTask = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });
    if (task.createdBy.toString() !== req.user.id) {
      return res.status(403).json({ message: 'Bạn không có quyền chỉnh sửa công việc này' });
    }
    const { title, description, startDate, dueDate, priority, status } = req.body;
    if (title !== undefined) task.title = title;
    if (description !== undefined) task.description = description;
    if (startDate !== undefined) task.startDate = startDate;
    if (dueDate !== undefined) task.dueDate = dueDate;
    if (priority !== undefined) task.priority = priority;
    if (status !== undefined) task.status = status;

    await task.save();
    res.json(task);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi cập nhật công việc', error: err.message });
  }
};

exports.updateTaskStatus = async (req, res) => {
  try {
    const { status } = req.body;
    if (!['todo', 'in_progress', 'completed'].includes(status)) {
      return res.status(400).json({ message: 'Trạng thái không hợp lệ' });
    }
    const task = await Task.findByIdAndUpdate(req.params.id, { status }, { new: true });
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });
    res.json(task);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi cập nhật trạng thái', error: err.message });
  }
};

exports.deleteTask = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);
    if (!task) return res.status(404).json({ message: 'Không tìm thấy công việc' });
    if (task.createdBy.toString() !== req.user.id) {
      return res.status(403).json({ message: 'Chỉ người tạo mới được xóa công việc' });
    }
    await task.deleteOne();
    res.json({ message: 'Đã xóa công việc thành công' });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi xóa công việc', error: err.message });
  }
};