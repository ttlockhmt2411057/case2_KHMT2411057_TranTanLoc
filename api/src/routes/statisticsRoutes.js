const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const statisticsController = require('../controllers/statisticsController');

router.use(authMiddleware);

router.get('/overview', statisticsController.getOverviewStatistics);

module.exports = router;