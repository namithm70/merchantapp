import express from 'express';
import cors from 'cors';
import { z } from 'zod';

import { query } from './db.js';

const app = express();
app.use(cors());
app.use(express.json());

const statusEnum = ['pending', 'countered', 'accepted', 'declined', 'expired'];

const offerSchema = z.object({
  listingId: z.string().min(1),
  threadId: z.string().uuid().optional().nullable(),
  amount: z.number().positive(),
  status: z.enum(statusEnum).optional(),
  expiresAt: z.string().datetime(),
  lastUpdatedBy: z.string().min(1),
});

app.get('/health', (req, res) => {
  res.json({ ok: true });
});

app.get('/offers', async (req, res) => {
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
  const { rows } = await query(`SELECT * FROM offers ${where} ORDER BY created_at DESC`, values);
  res.json(rows);
});

app.get('/offers/:id', async (req, res) => {
  const { rows } = await query('SELECT * FROM offers WHERE id = $1', [req.params.id]);
  if (!rows.length) return res.status(404).json({ error: 'Offer not found' });
  res.json(rows[0]);
});

app.post('/offers', async (req, res) => {
  const parsed = offerSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }

  const { listingId, threadId, amount, status, expiresAt, lastUpdatedBy } = parsed.data;
  const { rows } = await query(
    `INSERT INTO offers (listing_id, thread_id, amount, status, expires_at, last_updated_by)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING *`,
    [listingId, threadId ?? null, amount, status ?? 'pending', expiresAt, lastUpdatedBy],
  );
  res.status(201).json(rows[0]);
});

app.patch('/offers/:id', async (req, res) => {
  const parsed = offerSchema.partial().safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }

  const fields = [];
  const values = [];
  Object.entries(parsed.data).forEach(([key, value]) => {
    const column = key
      .replace(/([A-Z])/g, '_$1')
      .toLowerCase();
    values.push(value);
    fields.push(`${column} = $${values.length}`);
  });

  if (!fields.length) {
    return res.status(400).json({ error: 'No fields to update' });
  }

  values.push(req.params.id);
  const { rows } = await query(
    `UPDATE offers SET ${fields.join(', ')}, updated_at = NOW() WHERE id = $${values.length} RETURNING *`,
    values,
  );
  if (!rows.length) return res.status(404).json({ error: 'Offer not found' });
  res.json(rows[0]);
});

const port = process.env.PORT || 4003;
app.listen(port, () => {
  console.log(`Offers service listening on ${port}`);
});
