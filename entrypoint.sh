#!/bin/bash

echo "🕓 $(date) | Starting Odoo entrypoint on container: $(hostname)"

# Build odoo.conf từ template
echo "🛠️ Generating /etc/odoo/odoo.conf from /odoo.conf.template"
envsubst < /odoo.conf.template > /etc/odoo/odoo.conf

# Fix quyền cho thư mục filestore (nếu volume mount từ host)
echo "🔧 Fixing permissions for Odoo data directory"
mkdir -p /home/odoo/.local/share/Odoo
chown -R odoo:odoo /home/odoo/.local/share/Odoo

# Chờ PostgreSQL sẵn sàng
echo "⏳ Waiting for PostgreSQL to be ready..."

MAX_RETRIES=30
COUNT=0
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" >/dev/null 2>&1; do
  sleep 2
  COUNT=$((COUNT+1))
  echo "⏳ PostgreSQL not ready yet... ($COUNT/$MAX_RETRIES)"
  if [ "$COUNT" -ge "$MAX_RETRIES" ]; then
    echo "❌ PostgreSQL is still not ready after $MAX_RETRIES retries. Exiting."
    exit 1
  fi
done

echo "✅ PostgreSQL is ready!"

# Kiểm tra database đã tồn tại
echo "🔍 Checking if database '${DB_NAME}' exists..."
DB_EXISTS=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -p "$DB_PORT" -tAc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'")

if [ "$DB_EXISTS" != "1" ]; then
  echo "🟢 Database chưa tồn tại → init với '-i base'"
  exec python odoo-bin -c /etc/odoo/odoo.conf -i base --without-demo=all
else
  echo "✅ Database đã tồn tại → chạy Odoo bình thường"
  exec python odoo-bin -c /etc/odoo/odoo.conf
fi
