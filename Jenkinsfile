pipeline {
  agent any

  environment {
    IMAGE_NAME = 'odoo-custom:latest'
    CONTAINER_NAME = 'odoo_app_jenkins'

    // Thông tin database
    DB_HOST = '172.17.0.1'           // dùng host.docker.internal nếu chạy Docker Desktop
    DB_PORT = '25432'
    DB_USER = 'odoo_test'
    DB_NAME = 'odoo_test3'
    DB_PASSWORD = credentials('jenkins-db-pass')
    ADMIN_PASSWD = credentials('jenkins-admin-pass')
  }

  stages {
    stage('Start PostgreSQL') {
      steps {
        echo "🚀 Tạo container PostgreSQL cho Odoo"
        sh """
          docker rm -f pg_odoo_jenkins || true

          docker run -d \
            --name pg_odoo_jenkins \
            -e POSTGRES_USER=${DB_USER} \
            -e POSTGRES_PASSWORD=${DB_PASSWORD} \
            -e POSTGRES_DB=${DB_NAME} \
            -p ${DB_PORT}:5432 \
            postgres:14

          echo "⏳ Đợi PostgreSQL khởi động"
          sleep 10
        """
      }
    }

    stage('Clone Source') {
      steps {
        echo "📦 Clone source từ Git"
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        echo "🐳 Build image Odoo"
        sh "docker build -t ${IMAGE_NAME} ."
      }
    }

    stage('Deploy Odoo Container') {
      steps {
        echo "🚀 Khởi chạy container Odoo"
        sh """
          docker rm -f ${CONTAINER_NAME} || true

          docker run -d \
            --name ${CONTAINER_NAME} \
            -p 8069:8069 \
            ${IMAGE_NAME}

          echo "⏳ Chờ container Odoo sẵn sàng"
          sleep 5
        """
      }
    }

    stage('Inject odoo.conf') {
      steps {
        echo "🛠️ Tạo file odoo.conf bên trong container"
        sh """
          docker exec ${CONTAINER_NAME} bash -c 'cat > /etc/odoo/odoo.conf' <<EOF
[options]
addons_path = /opt/odoo/addons
admin_passwd = ${ADMIN_PASSWD}
db_host = ${DB_HOST}
db_port = ${DB_PORT}
db_user = ${DB_USER}
db_password = ${DB_PASSWORD}
db_name = ${DB_NAME}
logfile = /var/log/odoo/odoo.log
EOF
        """
      }
    }

    stage('Restart Odoo with config') {
      steps {
        echo "🔄 Restart Odoo với file cấu hình mới"
        sh """
          docker restart ${CONTAINER_NAME}
        """
      }
    }
  }
}
