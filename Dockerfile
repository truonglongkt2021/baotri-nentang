# Base image
FROM python:3.10

# Cài dependencies hệ thống + nano + gettext (envsubst) + postgresql-client
RUN apt-get update && apt-get install -y \
    postgresql-client \
    libpq-dev gcc python3-dev \
    libxml2-dev libxslt1-dev libjpeg-dev \
    zlib1g-dev libsasl2-dev libldap2-dev \
    libffi-dev liblcms2-dev libblas-dev libatlas-base-dev \
    libjpeg62-turbo-dev libtiff5-dev libfreetype6-dev \
    libwebp-dev libharfbuzz-dev libfribidi-dev \
    libxcb1-dev node-less npm \
    nano gettext && \
    npm install -g less less-plugin-clean-css && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Tạo user 'odoo' (không phải root)
RUN useradd -m -U -r -s /bin/bash odoo

# Thiết lập thư mục làm việc
WORKDIR /opt/odoo

# Copy toàn bộ source code và file cấu hình vào container
COPY . /opt/odoo
COPY odoo.conf.template /odoo.conf.template

# Cài Python dependencies (giả định đã có requirements.txt)
RUN pip install --upgrade pip && pip install -r requirements.txt

# Tạo thư mục cấu hình Odoo và cấp quyền cho user odoo
RUN mkdir -p /etc/odoo && \
    chown -R odoo:odoo /etc/odoo /opt/odoo /odoo.conf.template && \
    chmod +x /opt/odoo/entrypoint.sh

# Chạy bằng user 'odoo' để tránh lỗi quyền filestore
USER odoo

# Gọi entrypoint script (script này sẽ tự kiểm tra DB và init nếu cần)
ENTRYPOINT ["/opt/odoo/entrypoint.sh"]
