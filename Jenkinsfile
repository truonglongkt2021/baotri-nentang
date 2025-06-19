pipeline {
  agent any

  environment {
    IMAGE_NAME = 'odoo-custom:latest'
    CONTAINER_NAME = 'odoo_app_jenkins'

    // Database info
    DB_HOST = '172.17.0.1'
    DB_PORT = '25432'
    DB_USER = 'odoo_test'
    DB_NAME = 'odoo_test3'
    DB_PASSWORD = credentials('jenkins-db-pass')
    ADMIN_PASSWD = credentials('jenkins-admin-pass')
  }

  stages {
    stage('Start PostgreSQL') {
      steps {
        echo "🚀 Tạo container PostgreSQL"
        sh """
          docker rm -f pg_odoo_jenkins || true
          docker run -d \
            --name pg_odoo_jenkins \
            -e POSTGRES_USER=${DB_USER} \
            -e POSTGRES_PASSWORD=${DB_PASSWORD} \
            -e POSTGRES_DB=${DB_NAME} \
            -p ${DB_PORT}:5432 \
            postgres:14
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

    stage('Prepare odoo.conf') {
      steps {
        echo "📝 Tạo file cấu hình odoo.conf"
        writeFile file: 'odoo.conf', text: """
[options]
addons_path = /opt/odoo/addons
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

    stage('Deploy Odoo Container') {
      steps {
        echo "🚀 Khởi chạy container Odoo với cấu hình mount"
        sh """
          docker rm -f ${CONTAINER_NAME} || true
          docker run -d \
            --name ${CONTAINER_NAME} \
            -p 8068:8069 \
            -v ${env.WORKSPACE}/odoo.conf:/etc/odoo/odoo.conf \
            ${IMAGE_NAME}
          sleep 5
        """
      }
    }
  }

  post {
    failure {
      echo "❌ Đã xảy ra lỗi trong quá trình deploy."
    }
    success {
      echo "✅ Deploy thành công!"
    }
  }
}
