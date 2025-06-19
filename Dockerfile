# Base image
FROM python:3.10

# Cài dependencies cần thiết cho Odoo
RUN apt-get update && apt-get install -y \
    libpq-dev gcc python3-dev \
    libxml2-dev libxslt1-dev libjpeg-dev \
    zlib1g-dev libsasl2-dev libldap2-dev \
    libffi-dev liblcms2-dev \
    libblas-dev libatlas-base-dev \
    libjpeg62-turbo-dev libtiff5-dev libfreetype6-dev \
    libwebp-dev libharfbuzz-dev libfribidi-dev \
    libxcb1-dev node-less npm && \
    npm install -g less less-plugin-clean-css && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Tạo user 'odoo' không cần quyền root
RUN useradd -m -U -r -s /bin/bash odoo

# Copy source code + entrypoint script
WORKDIR /opt/odoo
COPY . /opt/odoo
COPY entrypoint.sh /opt/odoo/entrypoint.sh

# Cài Python dependencies
RUN pip install --upgrade pip && pip install -r requirements.txt

# Tạo thư mục cấu hình và cấp quyền
RUN mkdir -p /etc/odoo && \
    chown -R odoo:odoo /etc/odoo /opt/odoo && \
    chmod +x /opt/odoo/entrypoint.sh

# Chạy bằng user odoo
USER odoo

# Gọi entrypoint script (đã kiểm tra DB và tự quyết định khởi tạo hay không)
ENTRYPOINT ["/opt/odoo/entrypoint.sh"]
