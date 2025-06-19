#!/bin/bash

echo "🕓 $(date) | Starting Odoo entrypoint on container: $(hostname)"

# Tạo file cấu hình
echo "[options]" > /etc/odoo/odoo.conf
echo "addons_path = /opt/odoo/addons" >> /etc/odoo/odoo.conf
echo "admin_passwd = ${ADMIN_PASSWD}" >> /etc/odoo/odoo.conf
echo "db_host = ${DB_HOST}" >> /etc/odoo/odoo.conf
echo "db_port = ${DB_PORT}" >> /etc/odoo/odoo.conf
echo "db_user = ${DB_USER}" >> /etc/odoo/odoo.conf
echo "db_password = ${DB_PASSWORD}" >> /etc/odoo/odoo.conf
echo "db_name = ${DB_NAME}" >> /etc/odoo/odoo.conf
echo "logfile = /var/log/odoo/odoo.log" >> /etc/odoo/odoo.conf

# Kiểm tra DB sẵn sàng
echo "⏳ Waiting for PostgreSQL to be ready..."
sleep 5

if ! pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER >/dev/null 2>&1; then
  echo "❌ PostgreSQL is not ready!"
  exit 1
fi

# Kiểm tra database có tồn tại không
echo "🔍 Checking if database '${DB_NAME}' exists..."
DB_EXISTS=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -p $DB_PORT -tAc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'")

if [ "$DB_EXISTS" != "1" ]; then
  echo "🟢 Database chưa tồn tại → init với '-i base'"
  exec python odoo-bin -c /etc/odoo/odoo.conf -i base --without-demo=all
else
  echo "✅ Database đã tồn tại → chạy Odoo bình thường"
  exec python odoo-bin -c /etc/odoo/odoo.conf
fi
