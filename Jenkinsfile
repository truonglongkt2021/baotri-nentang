pipeline {
  agent any

  environment {
    IMAGE_NAME = 'odoo-custom:latest'
    CONTAINER_NAME = 'odoo_app_jenkins'

    // Database info
    DB_HOST = '172.17.0.1'          // host máy thật nếu dùng docker đơn lẻ
    DB_PORT = '25432'
    DB_USER = 'odoo_test'
    DB_NAME = 'odoo_test3'
    DB_PASSWORD = credentials('jenkins-db-pass')
    ADMIN_PASSWD = credentials('jenkins-admin-pass')
  }

  stages {
    stage('Start PostgreSQL') {
      steps {
        echo "🚀 Tạo PostgreSQL container cho Odoo"
        sh '''
          docker rm -f pg_odoo_jenkins || true

          docker run -d \
            --name pg_odoo_jenkins \
            -e POSTGRES_USER=odoo_test \
            -e POSTGRES_PASSWORD=secret123 \
            -e POSTGRES_DB=odoo_test3 \
            -p 25432:5432 \
            postgres:14

          echo "⏳ Đợi PostgreSQL khởi động"
          sleep 10
        '''
      }
    }

    stage('Clone Source') {
      steps {
        echo "📦 Clone source từ Git"
        checkout scm
      }
    }

    stage('Generate odoo.conf') {
      steps {
        echo "⚙️ Tạo file odoo.conf"
        writeFile file: 'odoo.conf', text: """
[options]
addons_path = addons
admin_passwd = ${ADMIN_PASSWD}
db_host = ${DB_HOST}
db_port = ${DB_PORT}
db_user = ${DB_USER}
db_password = ${DB_PASSWORD}
db_name = ${DB_NAME}
logfile = /var/log/odoo/odoo.log
"""
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
        echo "🚀 Deploy container Odoo"
        sh '''
          docker rm -f $CONTAINER_NAME || true
          docker run -d \
            --name $CONTAINER_NAME \
            -p 8069:8069 \
            -v "$WORKSPACE/odoo.conf:/etc/odoo/odoo.conf" \
            $IMAGE_NAME
        '''
      }
    }
  }
}
