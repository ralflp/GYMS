# Guía de Instalación en VPS (Ubuntu)

Sigue estos pasos una vez que compres tu VPS (DigitalOcean, Hostinger, etc.) e instales Ubuntu.

## 1. Instalar requerimientos (Docker y Git)

Conéctate por SSH a tu servidor y ejecuta esto para instalar Docker y Git:

```bash
sudo apt update
sudo apt install -y git docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker
```

## 2. Descargar el código

Descarga el código directamente desde tu repositorio de GitHub:

```bash
# Cambia 'tu-usuario' por tu nombre de usuario en GitHub
git clone https://github.com/ralflp/GYMS.git
cd GYMS
```

## 3. Arrancar el sistema (La primera vez)

Corre el script mágico de despliegue que preparamos. Este script descargará cualquier actualización y encenderá la base de datos y el backend.

```bash
./deploy.sh
```

¡Listo! Tu backend estará funcionando en `http://IP_DE_TU_VPS:3000`.

## 4. (Opcional) Actualizaciones Automáticas

Si quieres que tu servidor se actualice automáticamente cada medianoche si haces cambios en el código, puedes crear un cronjob:

```bash
crontab -e
```
Y añade esta línea al final del archivo:
```bash
0 0 * * * cd /ruta/a/tu/GYMS && ./deploy.sh >> /var/log/gym_deploy.log 2>&1
```
