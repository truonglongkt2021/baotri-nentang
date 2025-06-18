FROM python:3.10

# Cài dependencies
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

# Tạo user odoo
RUN useradd -m -U -r -s /bin/bash odoo

WORKDIR /opt/odoo
COPY . /opt/odoo

# Nâng cấp pip và cài requirements
RUN pip install --upgrade pip && pip install -r requirements.txt

USER root
RUN mkdir -p /etc/odoo && chown odoo:odoo /etc/odoo

USER odoo

CMD ["python", "odoo-bin", "-c", "/etc/odoo/odoo.conf"]
