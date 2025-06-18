pipeline {
  agent any

  environment {
    IMAGE_NAME = 'odoo-custom:latest'
    CONTAINER_NAME = 'odoo_app_jenkins'

    // 👉 Các biến được tạo từ Jenkins Credentials hoặc hardcoded 
    DB_HOST = '103.48.193.165'
    DB_PORT = '15432'
    DB_USER = 'odoo-test'
    DB_NAME = 'odoo-test3'

    // Dùng Jenkins credentials
    DB_PASSWORD = credentials('jenkins-db-pass')  // 📌 tạo trong Jenkins
    ADMIN_PASSWD = credentials('jenkins-admin-pass')
  }

  stages {
    stage('Clone') {
      steps {
        echo "📦 Lấy source từ Git"
        checkout scm
      }
    }

    stage('Generate odoo.conf') {
      steps {
        echo "⚙️ Tạo file odoo.conf từ template"
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
        sh "docker build -t $IMAGE_NAME ."
      }
    }

    stage('Deploy Container') {
      steps {
        echo "🚀 Deploy container Odoo"
        sh """
          docker rm -f $CONTAINER_NAME || true
          docker run -d \\
            --name $CONTAINER_NAME \\
            -p 8069:8069 \\
            -v \$(pwd)/odoo.conf:/opt/odoo/odoo.conf \\
            $IMAGE_NAME
        """
      }
    }
  }
}
