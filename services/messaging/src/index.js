import http from 'http';
import express from 'express';
import cors from 'cors';
import { WebSocketServer } from 'ws';
import { z } from 'zod';

import { query } from './db.js';

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const wss = new WebSocketServer({ server });

const broadcast = (payload) => {
  const message = JSON.stringify(payload);
  wss.clients.forEach((client) => {
    if (client.readyState === 1) {
      client.send(message);
    }
  });
};

const threadSchema = z.object({
  listingTitle: z.string().min(1),
  sellerName: z.string().min(1),
});

const messageSchema = z.object({
  sender: z.enum(['buyer', 'seller']),
  body: z.string().min(1).optional().nullable(),
  imageUrl: z.string().url().optional().nullable(),
});

app.get('/health', (req, res) => {
  res.json({ ok: true });
});

app.get('/threads', async (req, res) => {
  const { rows } = await query('SELECT * FROM threads ORDER BY last_message_at DESC');
  res.json(rows);
});

app.post('/threads', async (req, res) => {
  const parsed = threadSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }

  const { listingTitle, sellerName } = parsed.data;
  const { rows } = await query(
    `INSERT INTO threads (listing_title, seller_name)
     VALUES ($1, $2)
     RETURNING *`,
    [listingTitle, sellerName],
  );
  res.status(201).json(rows[0]);
});

app.get('/threads/:id/messages', async (req, res) => {
  const { rows } = await query(
    'SELECT * FROM messages WHERE thread_id = $1 ORDER BY sent_at ASC',
    [req.params.id],
  );
  res.json(rows);
});

app.post('/threads/:id/messages', async (req, res) => {
  const parsed = messageSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }

  const { sender, body, imageUrl } = parsed.data;
  const { rows } = await query(
    `INSERT INTO messages (thread_id, sender, body, image_url)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [req.params.id, sender, body ?? null, imageUrl ?? null],
  );

  await query(
    `UPDATE threads
     SET preview = $1,
         last_message_at = NOW(),
         unread_count = CASE WHEN $2 = 'seller' THEN unread_count + 1 ELSE unread_count END
     WHERE id = $3`,
    [body ?? 'Attachment', sender, req.params.id],
  );

  broadcast({ type: 'message', payload: rows[0] });
  res.status(201).json(rows[0]);
});

app.post('/threads/:id/block', async (req, res) => {
  const blocked = Boolean(req.body.blocked);
  const { rows } = await query(
    'UPDATE threads SET blocked = $1 WHERE id = $2 RETURNING *',
    [blocked, req.params.id],
  );
  if (!rows.length) return res.status(404).json({ error: 'Thread not found' });
  res.json(rows[0]);
});

app.post('/threads/:id/report', async (req, res) => {
  const { rows } = await query(
    'UPDATE threads SET reported = TRUE WHERE id = $1 RETURNING *',
    [req.params.id],
  );
  if (!rows.length) return res.status(404).json({ error: 'Thread not found' });
  res.json(rows[0]);
});

const port = process.env.PORT || 4002;
server.listen(port, () => {
  console.log(`Messaging service listening on ${port}`);
});
