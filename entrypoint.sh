#!/bin/bash

echo "[options]" > /etc/odoo/odoo.conf
echo "addons_path = /opt/odoo/addons" >> /etc/odoo/odoo.conf
echo "admin_passwd = ${ADMIN_PASSWD}" >> /etc/odoo/odoo.conf
echo "db_host = ${DB_HOST}" >> /etc/odoo/odoo.conf
echo "db_port = ${DB_PORT}" >> /etc/odoo/odoo.conf
echo "db_user = ${DB_USER}" >> /etc/odoo/odoo.conf
echo "db_password = ${DB_PASSWORD}" >> /etc/odoo/odoo.conf
echo "db_name = ${DB_NAME}" >> /etc/odoo/odoo.conf
echo "logfile = /var/log/odoo/odoo.log" >> /etc/odoo/odoo.conf

exec python odoo-bin -c /etc/odoo/odoo.conf
