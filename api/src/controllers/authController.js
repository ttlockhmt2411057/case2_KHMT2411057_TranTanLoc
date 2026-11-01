const User = require('../models/User');
const bcrypt = require('bcryptjs');

exports.register = async (req, res) => {
  try {
    const { fullName, email, password } = req.body;

    if (!fullName || !email || !password) {
      return res.status(400).json({ message: 'Vui long dien day du ho ten, email va mat khau' });
    }

    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ message: 'Email nay da duoc su dung' });
    }

    // Bam mat khau bang bcrypt theo yeu cau bao mat muc 9
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const user = await User.create({
      fullName,
      email,
      passwordHash,
    });

    return res.status(201).json({
      message: 'Dang ky tai khoan thanh cong',
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
      },
    });
  } catch (error) {
    console.error('Loi dang ky:', error);
    return res.status(500).json({ message: 'Loi he thong' });
  }
};