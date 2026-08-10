import { Request, Response, NextFunction } from 'express';
import { query } from '../config/db';

export interface TenantRequest extends Request {
  tenantId?: string;
  tenantDb?: string;
}

export const resolveTenant = async (req: TenantRequest, res: Response, next: NextFunction) => {
  // We expect a header 'X-Tenant-ID' or similar
  const tenantId = req.headers['x-tenant-id'] as string;

  if (!tenantId) {
    return res.status(400).json({ message: 'Tenant ID is required' });
  }

  try {
    const result = await query('SELECT db_name, status FROM tenants WHERE id = $1', [tenantId]);
    const tenant = result.rows[0];

    if (!tenant) {
      return res.status(404).json({ message: 'Tenant not found' });
    }

    if (tenant.status !== 'active') {
      return res.status(403).json({ message: `Tenant is ${tenant.status}` });
    }

    req.tenantId = tenantId;
    req.tenantDb = tenant.db_name;
    next();
  } catch (error) {
    console.error('Error resolving tenant:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};
