const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const shareController = require('../controllers/shareController');

router.use(authMiddleware);

router.post('/:taskId', shareController.shareTask);
router.get('/:taskId', shareController.getTaskShares);
router.delete('/:taskId/:shareId', shareController.removeTaskShare);

module.exports = router;