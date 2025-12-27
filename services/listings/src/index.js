import express from 'express';
import cors from 'cors';
import { z } from 'zod';

import { query } from './db.js';

const app = express();
app.use(cors());
app.use(express.json());

const conditionEnum = ['New', 'Like New', 'Good', 'Fair', 'For Parts'];

const listingSchema = z.object({
  title: z.string().min(1),
  category: z.string().min(1),
  condition: z.enum(conditionEnum),
  price: z.number().positive(),
  location: z.string().min(1),
  description: z.string().optional().nullable(),
});

app.get('/health', (req, res) => {
  res.json({ ok: true });
});

app.get('/listings', async (req, res) => {
  const { status, condition, category } = req.query;
  const filters = [];
  const values = [];

  if (status) {
    values.push(status);
    filters.push(`status = $${values.length}`);
  }
  if (condition) {
    values.push(condition);
    filters.push(`condition = $${values.length}`);
  }
  if (category) {
    values.push(category);
    filters.push(`category = $${values.length}`);
  }

  const whereClause = filters.length ? `WHERE ${filters.join(' AND ')}` : '';
  const { rows } = await query(
    `SELECT * FROM listings ${whereClause} ORDER BY created_at DESC`,
    values,
  );
  res.json(rows);
});

app.get('/listings/:id', async (req, res) => {
  const { rows } = await query('SELECT * FROM listings WHERE id = $1', [req.params.id]);
  if (!rows.length) return res.status(404).json({ error: 'Listing not found' });
  res.json(rows[0]);
});

app.post('/listings', async (req, res) => {
  const parsed = listingSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }

  const { title, category, condition, price, location, description } = parsed.data;
  const { rows } = await query(
    `INSERT INTO listings (title, category, condition, price, location, description)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING *`,
    [title, category, condition, price, location, description ?? null],
  );
  res.status(201).json(rows[0]);
});

app.patch('/listings/:id', async (req, res) => {
  const parsed = listingSchema.partial().safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }

  const fields = [];
  const values = [];
  Object.entries(parsed.data).forEach(([key, value]) => {
    values.push(value);
    fields.push(`${key} = $${values.length}`);
  });

  if (!fields.length) {
    return res.status(400).json({ error: 'No fields to update' });
  }

  values.push(req.params.id);
  const { rows } = await query(
    `UPDATE listings SET ${fields.join(', ')}, updated_at = NOW() WHERE id = $${values.length} RETURNING *`,
    values,
  );

  if (!rows.length) return res.status(404).json({ error: 'Listing not found' });
  res.json(rows[0]);
});

app.post('/listings/:id/publish', async (req, res) => {
  const { rows } = await query(
    `UPDATE listings SET status = 'published', updated_at = NOW() WHERE id = $1 RETURNING *`,
    [req.params.id],
  );
  if (!rows.length) return res.status(404).json({ error: 'Listing not found' });
  res.json(rows[0]);
});

app.post('/listings/:id/archive', async (req, res) => {
  const { rows } = await query(
    `UPDATE listings SET status = 'archived', updated_at = NOW() WHERE id = $1 RETURNING *`,
    [req.params.id],
  );
  if (!rows.length) return res.status(404).json({ error: 'Listing not found' });
  res.json(rows[0]);
});

const port = process.env.PORT || 4001;
app.listen(port, () => {
  console.log(`Listings service listening on ${port}`);
});
