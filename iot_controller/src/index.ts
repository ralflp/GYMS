import { io, Socket } from 'socket.io-client';
import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

const TENANT_ID = process.env.TENANT_ID || '1';
const SERVER_URL = process.env.SERVER_URL || 'http://localhost:3000';
const HIKVISION_IP = process.env.HIKVISION_IP || '192.168.1.64';
const HIKVISION_USER = process.env.HIKVISION_USER || 'admin';
const HIKVISION_PASS = process.env.HIKVISION_PASS || 'password123';

console.log(`Starting IoT Controller for Tenant ID: ${TENANT_ID}`);
console.log(`Connecting to Cloud Server: ${SERVER_URL}`);

// Conectar al servidor en la nube y autenticarse como este tenant específico
const socket: Socket = io(SERVER_URL, {
  auth: {
    tenantId: TENANT_ID
  }
});

socket.on('connect', () => {
  console.log('Connected to Cloud Server. Socket ID:', socket.id);
});

socket.on('disconnect', () => {
  console.log('Disconnected from Cloud Server');
});

// Escuchar el evento de actualización de membresía emitido desde el punto de venta
socket.on('update_membership', async (data: { hikvisionId: string, startDate: string, endDate: string }) => {
  console.log('Received update_membership event:', data);

  if (!data.hikvisionId) {
    console.error('No hikvisionId provided. Cannot update terminal.');
    return;
  }

  try {
    // 1. Get the existing user data from Hikvision terminal via ISAPI
    // Note: Digest authentication is required by Hikvision. Axios handles basic auth easily,
    // but for Digest auth in a real production scenario, a library like 'urllib' or custom interceptor is needed.
    // For this boilerplate, we'll demonstrate the API endpoint structure.

    console.log(`Updating Hikvision Terminal (${HIKVISION_IP}) for user ${data.hikvisionId}...`);

    // ISAPI Endpoint to get user info: GET /ISAPI/AccessControl/UserInfo/Search
    // ISAPI Endpoint to set user info: PUT /ISAPI/AccessControl/UserInfo/SetUp?format=json

    const payload = {
      UserInfoDetail: {
        mode: "byEmployeeNo",
        EmployeeNo: data.hikvisionId,
        Valid: {
          enable: true,
          beginTime: `${data.startDate}T00:00:00`,
          endTime: `${data.endDate}T23:59:59`
        }
      }
    };

    /* Example request (commented out until actual Hikvision device is available):
    const response = await axios.put(`http://${HIKVISION_IP}/ISAPI/AccessControl/UserInfo/SetUp?format=json`, payload, {
      auth: {
        username: HIKVISION_USER,
        password: HIKVISION_PASS
      }
    });
    console.log('Hikvision terminal updated successfully:', response.data);
    */

    console.log('Mock: Hikvision terminal updated successfully with payload:', JSON.stringify(payload, null, 2));

  } catch (error) {
    console.error('Error communicating with Hikvision terminal:', error);
  }
});
