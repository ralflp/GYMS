import { Server as HttpServer } from 'http';
import { Server, Socket } from 'socket.io';
import { query } from './db';

let io: Server;

export const initSocket = (server: HttpServer) => {
  io = new Server(server, {
    cors: {
      origin: '*',
    },
  });

  io.use(async (socket: Socket, next) => {
    const tenantId = socket.handshake.auth.tenantId;
    if (!tenantId) {
      return next(new Error('Authentication error: tenantId required'));
    }

    try {
      // Validate tenant exists and is active
      const result = await query('SELECT status FROM tenants WHERE id = $1', [tenantId]);
      const tenant = result.rows[0];

      if (!tenant || tenant.status !== 'active') {
        return next(new Error('Authentication error: Invalid or inactive tenant'));
      }

      // Join a room specific to this tenant
      socket.join(`tenant_${tenantId}`);
      console.log(`Socket connected and joined room: tenant_${tenantId}`);
      next();
    } catch (error) {
      console.error('Socket authentication error:', error);
      next(new Error('Internal server error'));
    }
  });

  io.on('connection', (socket: Socket) => {
    socket.on('disconnect', () => {
      console.log('Socket disconnected:', socket.id);
    });
  });

  return io;
};

export const getIo = () => {
  if (!io) {
    throw new Error('Socket.io not initialized!');
  }
  return io;
};
