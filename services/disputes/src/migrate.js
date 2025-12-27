import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

import { query, close } from './db.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const migrationsDir = path.resolve(__dirname, '../migrations');

const run = async () => {
  const files = fs.readdirSync(migrationsDir).filter((file) => file.endsWith('.sql'));
  files.sort();

  for (const file of files) {
    const sql = fs.readFileSync(path.join(migrationsDir, file), 'utf-8');
    await query(sql);
  }

  await close();
};

run().catch((error) => {
  console.error(error);
  process.exit(1);
});
