import express from 'express';
import cors from 'cors';
import { z } from 'zod';

import { query } from './db.js';

const app = express();
app.use(cors());
app.use(express.json());

const channelEnum = ['push', 'email', 'sms', 'in_app'];
const statusEnum = ['queued', 'sent', 'failed'];

const preferenceSchema = z.object({
  userId: z.string().min(1),
  pushEnabled: z.boolean().optional(),
  emailEnabled: z.boolean().optional(),
  smsEnabled: z.boolean().optional(),
});

const notificationSchema = z.object({
  userId: z.string().min(1),
  channel: z.enum(channelEnum),
  title: z.string().min(1),
  body: z.string().min(1),
});

app.get('/health', (req, res) => {
  res.json({ ok: true });
});

app.get('/preferences/:userId', async (req, res) => {
  const { rows } = await query(
    'SELECT * FROM notification_preferences WHERE user_id = $1',
    [req.params.userId],
  );
  if (!rows.length) {
    return res.json({
      userId: req.params.userId,
      pushEnabled: true,
      emailEnabled: true,
      smsEnabled: false,
    });
  }
  res.json({
    userId: rows[0].user_id,
    pushEnabled: rows[0].push_enabled,
    emailEnabled: rows[0].email_enabled,
    smsEnabled: rows[0].sms_enabled,
  });
});

app.post('/preferences', async (req, res) => {
  const parsed = preferenceSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }

  const { userId, pushEnabled, emailEnabled, smsEnabled } = parsed.data;
  const { rows } = await query(
    `INSERT INTO notification_preferences (user_id, push_enabled, email_enabled, sms_enabled)
     VALUES ($1, $2, $3, $4)
     ON CONFLICT (user_id)
     DO UPDATE SET push_enabled = COALESCE($2, notification_preferences.push_enabled),
                   email_enabled = COALESCE($3, notification_preferences.email_enabled),
                   sms_enabled = COALESCE($4, notification_preferences.sms_enabled),
                   updated_at = NOW()
     RETURNING *`,
    [
      userId,
      pushEnabled ?? null,
      emailEnabled ?? null,
      smsEnabled ?? null,
    ],
  );
  res.json(rows[0]);
});

app.post('/notifications', async (req, res) => {
  const parsed = notificationSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }

  const { userId, channel, title, body } = parsed.data;
  const { rows } = await query(
    `INSERT INTO notifications (user_id, channel, title, body, status)
     VALUES ($1, $2, $3, $4, 'queued')
     RETURNING *`,
    [userId, channel, title, body],
  );
  res.status(201).json(rows[0]);
});

app.get('/notifications', async (req, res) => {
  const { userId, status } = req.query;
  const filters = [];
  const values = [];

  if (userId) {
    values.push(userId);
    filters.push(`user_id = $${values.length}`);
  }
  if (status) {
    values.push(status);
    filters.push(`status = $${values.length}`);
  }

  const where = filters.length ? `WHERE ${filters.join(' AND ')}` : '';
  const { rows } = await query(
    `SELECT * FROM notifications ${where} ORDER BY created_at DESC`,
    values,
  );
  res.json(rows);
});

app.patch('/notifications/:id', async (req, res) => {
  const parsed = z
    .object({ status: z.enum(statusEnum) })
    .safeParse(req.body);

  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }

  const { rows } = await query(
    `UPDATE notifications SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING *`,
    [parsed.data.status, req.params.id],
  );
  if (!rows.length) return res.status(404).json({ error: 'Notification not found' });
  res.json(rows[0]);
});

const port = process.env.PORT || 4006;
app.listen(port, () => {
  console.log(`Notifications service listening on ${port}`);
});
