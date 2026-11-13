const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');

exports.getOverviewStatistics = async (req, res) => {
  try {
    const userId = req.user.id;
    const sharedRecords = await TaskShare.find({ sharedWithUserId: userId }).select('taskId');
    const sharedTaskIds = sharedRecords.map((s) => s.taskId);

    const allTasks = await Task.find({
      $or: [{ createdBy: userId }, { _id: { $in: sharedTaskIds } }],
    });

    const now = new Date();
    const next48Hours = new Date(now.getTime() + 48 * 60 * 60 * 1000);

    const stats = {
      total: allTasks.length,
      createdCount: allTasks.filter((t) => t.createdBy.toString() === userId).length,
      assignedCount: sharedTaskIds.length,
      todo: allTasks.filter((t) => t.status === 'todo').length,
      inProgress: allTasks.filter((t) => t.status === 'in_progress').length,
      completed: allTasks.filter((t) => t.status === 'completed').length,
      overdue: allTasks.filter(
        (t) => t.status !== 'completed' && new Date(t.dueDate) < now
      ).length,
      dueSoon: allTasks.filter(
        (t) =>
          t.status !== 'completed' &&
          new Date(t.dueDate) >= now &&
          new Date(t.dueDate) <= next48Hours
      ).length,
    };

    res.status(200).json(stats);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi lấy dữ liệu thống kê', error: error.message });
  }
};