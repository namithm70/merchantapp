import express from 'express';
import cors from 'cors';
import { z } from 'zod';

import { query } from './db.js';

const app = express();
app.use(cors());
app.use(express.json());

const statusEnum = ['initiated', 'held', 'released', 'refunded', 'failed'];

const paymentSchema = z.object({
  listingId: z.string().min(1),
  buyerId: z.string().min(1),
  amount: z.number().positive(),
  holdUntil: z.string().datetime().optional().nullable(),
});

app.get('/health', (req, res) => {
  res.json({ ok: true });
});

app.get('/payments', async (req, res) => {
  const { listingId, status } = req.query;
  const filters = [];
  const values = [];

  if (listingId) {
    values.push(listingId);
    filters.push(`listing_id = $${values.length}`);
  }
  if (status) {
    values.push(status);
    filters.push(`status = $${values.length}`);
  }

  const where = filters.length ? `WHERE ${filters.join(' AND ')}` : '';
  const { rows } = await query(`SELECT * FROM payments ${where} ORDER BY created_at DESC`, values);
  res.json(rows);
});

app.get('/payments/:id', async (req, res) => {
  const { rows } = await query('SELECT * FROM payments WHERE id = $1', [req.params.id]);
  if (!rows.length) return res.status(404).json({ error: 'Payment not found' });
  res.json(rows[0]);
});

app.post('/payments', async (req, res) => {
  const parsed = paymentSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }

  const { listingId, buyerId, amount, holdUntil } = parsed.data;
  const { rows } = await query(
    `INSERT INTO payments (listing_id, buyer_id, amount, hold_until)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [listingId, buyerId, amount, holdUntil ?? null],
  );
  res.status(201).json(rows[0]);
});

app.post('/payments/:id/hold', async (req, res) => {
  const holdUntil = req.body.holdUntil ?? null;
  const { rows } = await query(
    `UPDATE payments
     SET status = 'held', hold_until = $1, updated_at = NOW()
     WHERE id = $2 RETURNING *`,
    [holdUntil, req.params.id],
  );
  if (!rows.length) return res.status(404).json({ error: 'Payment not found' });
  res.json(rows[0]);
});

app.post('/payments/:id/release', async (req, res) => {
  const { rows } = await query(
    `UPDATE payments
     SET status = 'released', updated_at = NOW()
     WHERE id = $1 RETURNING *`,
    [req.params.id],
  );
  if (!rows.length) return res.status(404).json({ error: 'Payment not found' });
  res.json(rows[0]);
});

app.post('/payments/:id/refund', async (req, res) => {
  const { rows } = await query(
    `UPDATE payments
     SET status = 'refunded', updated_at = NOW()
     WHERE id = $1 RETURNING *`,
    [req.params.id],
  );
  if (!rows.length) return res.status(404).json({ error: 'Payment not found' });
  res.json(rows[0]);
});

app.post('/payments/:id/fail', async (req, res) => {
  const { rows } = await query(
    `UPDATE payments
     SET status = 'failed', updated_at = NOW()
     WHERE id = $1 RETURNING *`,
    [req.params.id],
  );
  if (!rows.length) return res.status(404).json({ error: 'Payment not found' });
  res.json(rows[0]);
});

const port = process.env.PORT || 4004;
app.listen(port, () => {
  console.log(`Payments service listening on ${port}`);
});
