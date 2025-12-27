import express from 'express';
import cors from 'cors';
import { z } from 'zod';

import { query } from './db.js';

const app = express();
app.use(cors());
app.use(express.json());

const statusEnum = ['open', 'under_review', 'resolved', 'closed'];

const disputeSchema = z.object({
  listingId: z.string().min(1),
  orderId: z.string().optional().nullable(),
  issueType: z.string().min(1),
  details: z.string().min(1),
  evidenceUrl: z.string().url().optional().nullable(),
});

app.get('/health', (req, res) => {
  res.json({ ok: true });
});

app.get('/disputes', async (req, res) => {
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
  const { rows } = await query(`SELECT * FROM disputes ${where} ORDER BY created_at DESC`, values);
  res.json(rows);
});

app.get('/disputes/:id', async (req, res) => {
  const { rows } = await query('SELECT * FROM disputes WHERE id = $1', [req.params.id]);
  if (!rows.length) return res.status(404).json({ error: 'Dispute not found' });
  res.json(rows[0]);
});

app.post('/disputes', async (req, res) => {
  const parsed = disputeSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }

  const { listingId, orderId, issueType, details, evidenceUrl } = parsed.data;
  const { rows } = await query(
    `INSERT INTO disputes (listing_id, order_id, issue_type, details, evidence_url)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING *`,
    [listingId, orderId ?? null, issueType, details, evidenceUrl ?? null],
  );
  res.status(201).json(rows[0]);
});

app.patch('/disputes/:id', async (req, res) => {
  const parsed = z
    .object({
      status: z.enum(statusEnum).optional(),
      evidenceUrl: z.string().url().optional().nullable(),
    })
    .safeParse(req.body);

  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }

  const fields = [];
  const values = [];
  Object.entries(parsed.data).forEach(([key, value]) => {
    const column = key.replace(/([A-Z])/g, '_$1').toLowerCase();
    values.push(value);
    fields.push(`${column} = $${values.length}`);
  });

  if (!fields.length) {
    return res.status(400).json({ error: 'No fields to update' });
  }

  values.push(req.params.id);
  const { rows } = await query(
    `UPDATE disputes SET ${fields.join(', ')}, updated_at = NOW() WHERE id = $${values.length} RETURNING *`,
    values,
  );
  if (!rows.length) return res.status(404).json({ error: 'Dispute not found' });
  res.json(rows[0]);
});

const port = process.env.PORT || 4005;
app.listen(port, () => {
  console.log(`Disputes service listening on ${port}`);
});
