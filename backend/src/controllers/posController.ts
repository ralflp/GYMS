import { Response } from 'express';
import { TenantRequest } from '../middleware/tenant';
import { getTenantPool } from '../config/tenantDb';

export const getProducts = async (req: TenantRequest, res: Response) => {
  const pool = getTenantPool(req.tenantDb!);
  try {
    const result = await pool.query('SELECT * FROM products ORDER BY name ASC');
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({ message: 'Error fetching products' });
  }
};

export const getMemberships = async (req: TenantRequest, res: Response) => {
  const pool = getTenantPool(req.tenantDb!);
  try {
    const result = await pool.query('SELECT * FROM memberships ORDER BY price ASC');
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching memberships:', error);
    res.status(500).json({ message: 'Error fetching memberships' });
  }
};

export const processSale = async (req: TenantRequest, res: Response) => {
  const pool = getTenantPool(req.tenantDb!);
  const client = await pool.connect();
  const { clientId, items, total } = req.body;
  // items format: [{ type: 'product', id: 1, quantity: 2, price: 50 }, { type: 'membership', id: 2, quantity: 1, price: 500 }]

  try {
    await client.query('BEGIN');

    // 1. Record the sale
    const saleResult = await client.query(
      'INSERT INTO sales (client_id, total) VALUES ($1, $2) RETURNING id',
      [clientId, total]
    );
    const saleId = saleResult.rows[0].id;

    // 2. Process items
    for (const item of items) {
      if (item.type === 'product') {
        await client.query(
          'INSERT INTO sale_items (sale_id, product_id, quantity, price) VALUES ($1, $2, $3, $4)',
          [saleId, item.id, item.quantity, item.price]
        );
        // Reduce stock
        await client.query(
          'UPDATE products SET stock = stock - $1 WHERE id = $2',
          [item.quantity, item.id]
        );
      } else if (item.type === 'membership') {
        await client.query(
          'INSERT INTO sale_items (sale_id, membership_id, quantity, price) VALUES ($1, $2, $3, $4)',
          [saleId, item.id, item.quantity, item.price]
        );

        // Find membership duration
        const memResult = await client.query('SELECT duration_days FROM memberships WHERE id = $1', [item.id]);
        const durationDays = memResult.rows[0].duration_days;

        // Add or extend membership for client
        const newMembership = await client.query(
          `INSERT INTO client_memberships (client_id, membership_id, start_date, end_date)
           VALUES ($1, $2, CURRENT_DATE, CURRENT_DATE + $3 * INTERVAL '1 day') RETURNING start_date, end_date`,
          [clientId, item.id, durationDays]
        );

        // Fetch client's Hikvision ID
        const clientResult = await client.query('SELECT face_id FROM clients WHERE id = $1', [clientId]);
        const faceId = clientResult.rows[0]?.face_id;

        if (faceId) {
          // Trigger Hikvision update via WebSocket to the Local IoT Controller
          const io = require('../config/socket').getIo();

          // Format dates as YYYY-MM-DD avoiding UTC shift issues with toISOString
          const sDate = new Date(newMembership.rows[0].start_date);
          const startDate = `${sDate.getFullYear()}-${String(sDate.getMonth() + 1).padStart(2, '0')}-${String(sDate.getDate()).padStart(2, '0')}`;

          const eDate = new Date(newMembership.rows[0].end_date);
          const endDate = `${eDate.getFullYear()}-${String(eDate.getMonth() + 1).padStart(2, '0')}-${String(eDate.getDate()).padStart(2, '0')}`;

          console.log(`Emitting update_membership to room tenant_${req.tenantId} for face_id ${faceId}`);
          io.to(`tenant_${req.tenantId}`).emit('update_membership', {
            hikvisionId: faceId,
            startDate,
            endDate
          });
        }
      }
    }

    await client.query('COMMIT');
    res.status(201).json({ message: 'Sale processed successfully', saleId });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error processing sale:', error);
    res.status(500).json({ message: 'Error processing sale' });
  } finally {
    client.release();
  }
};
