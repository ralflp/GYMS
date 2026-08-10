import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createServer } from 'http';
import authRoutes from './routes/authRoutes';
import tenantRoutes from './routes/tenantRoutes';
import { initSocket } from './config/socket';

dotenv.config();

const app = express();
const httpServer = createServer(app);

// Inicializar WebSockets
initSocket(httpServer);

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/tenants', tenantRoutes);
app.use('/api/gym', require('./routes/posRoutes').default); // Tenant-specific routes

app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'ok', message: 'API is running' });
});

const PORT = process.env.PORT || 3000;

httpServer.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
