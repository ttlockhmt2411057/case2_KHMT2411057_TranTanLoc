const nodemailer = require('nodemailer');
const EmailLog = require('../models/EmailLog');

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'smtp.gmail.com',
  port: Number(process.env.SMTP_PORT) || 587,
  secure: false,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

exports.sendTaskEmail = async ({ taskId, recipientEmail, eventType, subject, html }) => {
  const log = await EmailLog.create({
    taskId,
    recipientEmail,
    eventType,
    subject,
    status: 'pending',
    attempts: 1,
  });

  try {
    await transporter.sendMail({
      from: `"Task Manager App" <${process.env.SMTP_USER}>`,
      to: recipientEmail,
      subject,
      html,
    });

    log.status = 'sent';
    log.sentAt = new Date();
    await log.save();
    return log;
  } catch (error) {
    log.status = 'failed';
    log.errorMessage = error.message;
    await log.save();
    console.error('Lỗi gửi email:', error.message);
    return log;
  }
};