import fs from 'fs';
import http from 'http';
import express from 'express';
import cors from 'cors';
import { WebSocketServer } from 'ws';

const PORT = process.env.PORT || 4242;
const STORE_PATH = new URL('./storage.json', import.meta.url).pathname;

const app = express();
app.use(cors());
app.use(express.json());

const readStore = () => {
  const raw = fs.readFileSync(STORE_PATH, 'utf-8');
  return JSON.parse(raw);
};

const writeStore = (data) => {
  fs.writeFileSync(STORE_PATH, JSON.stringify(data, null, 2));
};

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

app.get('/threads', (req, res) => {
  const store = readStore();
  res.json(store.threads);
});

app.get('/threads/:id/messages', (req, res) => {
  const store = readStore();
  res.json(store.messages[req.params.id] || []);
});

app.post('/threads/:id/messages', (req, res) => {
  const store = readStore();
  const message = {
    id: `m-${Date.now()}`,
    threadId: req.params.id,
    sender: req.body.sender || 'buyer',
    body: req.body.body || null,
    imagePath: req.body.imagePath || null,
    sentAt: new Date().toISOString(),
  };
  store.messages[req.params.id] = store.messages[req.params.id] || [];
  store.messages[req.params.id].push(message);

  store.threads = store.threads.map((thread) => {
    if (thread.id !== req.params.id) return thread;
    return {
      ...thread,
      preview: message.body || 'Attachment',
      lastMessageAt: message.sentAt,
      unreadCount: message.sender === 'seller' ? (thread.unreadCount || 0) + 1 : thread.unreadCount,
    };
  });

  writeStore(store);
  broadcast({ type: 'message', payload: message });
  res.json(message);
});

app.post('/threads/:id/block', (req, res) => {
  const store = readStore();
  store.threads = store.threads.map((thread) => {
    if (thread.id !== req.params.id) return thread;
    return { ...thread, blocked: Boolean(req.body.blocked) };
  });
  writeStore(store);
  res.json({ ok: true });
});

app.post('/threads/:id/report', (req, res) => {
  const store = readStore();
  store.threads = store.threads.map((thread) => {
    if (thread.id !== req.params.id) return thread;
    return { ...thread, reported: true };
  });
  writeStore(store);
  res.json({ ok: true });
});

app.post('/threads/:id/offer', (req, res) => {
  const store = readStore();
  const offer = {
    amount: req.body.amount,
    status: req.body.status,
    expiresAt: req.body.expiresAt,
    lastUpdatedBy: req.body.lastUpdatedBy,
  };
  store.threads = store.threads.map((thread) => {
    if (thread.id !== req.params.id) return thread;
    return { ...thread, offerState: offer };
  });
  writeStore(store);
  broadcast({ type: 'offer', payload: { threadId: req.params.id, offer } });
  res.json({ ok: true });
});

app.post('/wishlist', (req, res) => {
  const store = readStore();
  const { listingId, action } = req.body;
  if (action === 'add' && !store.wishlist.includes(listingId)) {
    store.wishlist.push(listingId);
  }
  if (action === 'remove') {
    store.wishlist = store.wishlist.filter((id) => id !== listingId);
  }
  writeStore(store);
  res.json({ wishlist: store.wishlist });
});

app.get('/wishlist', (req, res) => {
  const store = readStore();
  res.json({ wishlist: store.wishlist || [] });
});

app.post('/pricing', (req, res) => {
  const store = readStore();
  const { category, price } = req.body;
  const base = store.pricing?.[category] || { low: 200, high: 300 };
  const parsed = Number(price) || 0;
  const delta = parsed > 0 ? Math.min(parsed * 0.08, 45) : 0;
  res.json({
    low: Math.max(20, base.low - delta),
    high: base.high + delta,
    confidence: 0.78,
    factors: ['Recent sales', 'Demand index', 'Condition'],
  });
});

app.post('/shipping/rates', (req, res) => {
  const { origin, destination } = req.body;
  res.json({
    origin,
    destination,
    rates: [
      { carrier: 'UPS', eta: '2-3 days', cost: 18.5 },
      { carrier: 'FedEx', eta: '1-2 days', cost: 24.2 },
      { carrier: 'USPS', eta: '3-4 days', cost: 12.9 },
    ],
  });
});

wss.on('connection', (socket) => {
  socket.send(JSON.stringify({ type: 'status', payload: 'connected' }));
});

server.listen(PORT, () => {
  console.log(`Marketplace server running on http://localhost:${PORT}`);
});
