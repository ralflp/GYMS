import { Request, Response } from 'express';
import { query } from '../config/db';
import { createDatabaseForTenant } from '../services/tenantService';

export const createTenant = async (req: Request, res: Response) => {
  const { name, email, phone } = req.body;
  const dbName = `gym_${name.toLowerCase().replace(/[^a-z0-9]/g, '_')}_${Date.now()}`;

  try {
    // 1. Create entry in master database
    const result = await query(
      'INSERT INTO tenants (name, db_name, status, email, phone) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [name, dbName, 'active', email, phone]
    );

    // 2. Create the actual database for the tenant
    await createDatabaseForTenant(dbName);

    res.status(201).json({ message: 'Tenant created successfully', tenant: result.rows[0] });
  } catch (error) {
    console.error('Error creating tenant:', error);
    res.status(500).json({ message: 'Error creating tenant' });
  }
};

export const getTenants = async (req: Request, res: Response) => {
  try {
    const result = await query('SELECT * FROM tenants ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching tenants:', error);
    res.status(500).json({ message: 'Error fetching tenants' });
  }
};

export const updateTenantStatus = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { status } = req.body; // 'active', 'paused', 'inactive'

  const validStatuses = ['active', 'paused', 'inactive'];
  if (!validStatuses.includes(status)) {
    return res.status(400).json({ message: 'Invalid status' });
  }

  try {
    const result = await query(
      'UPDATE tenants SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *',
      [status, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Tenant not found' });
    }

    res.json({ message: 'Tenant status updated successfully', tenant: result.rows[0] });
  } catch (error) {
    console.error('Error updating tenant status:', error);
    res.status(500).json({ message: 'Error updating tenant status' });
  }
};
