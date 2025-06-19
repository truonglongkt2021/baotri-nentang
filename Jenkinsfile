pipeline {
  agent any

  environment {
    IMAGE_NAME = 'odoo-custom:latest'
    CONTAINER_NAME = 'odoo_app_jenkins'
    NETWORK_NAME = 'odoo_net_jenkin'

    DB_HOST = 'pg_odoo_jenkins' // 👉 Truy cập bằng tên container
    DB_PORT = '5432'
    DB_USER = 'odoo_test'
    DB_NAME = 'odoo_test3'
    DB_PASSWORD = credentials('jenkins-db-pass')
    ADMIN_PASSWD = credentials('jenkins-admin-pass')
  }

  stages {
    stage('Create Docker Network') {
      steps {
        sh "docker network create ${NETWORK_NAME} || true"
      }
    }

    stage('Start PostgreSQL') {
      steps {
        sh """
          docker rm -f pg_odoo_jenkins || true
          docker run -d \
            --name pg_odoo_jenkins \
            --network ${NETWORK_NAME} \
            -e POSTGRES_USER=${DB_USER} \
            -e POSTGRES_PASSWORD=${DB_PASSWORD} \
            -e POSTGRES_DB=${DB_NAME} \
            postgres:14
        """
      }
    }

    stage('Clone Source') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        sh "docker build -t ${IMAGE_NAME} ."
      }
    }

    stage('Deploy Odoo Container') {
      steps {
        sh """
          docker rm -f ${CONTAINER_NAME} || true
          docker run -d \
            --name ${CONTAINER_NAME} \
            --network ${NETWORK_NAME} \
            -p 8068:8069 \
            -e DB_HOST=${DB_HOST} \
            -e DB_PORT=${DB_PORT} \
            -e DB_USER=${DB_USER} \
            -e DB_PASSWORD=${DB_PASSWORD} \
            -e DB_NAME=${DB_NAME} \
            -e ADMIN_PASSWD=${ADMIN_PASSWD} \
            ${IMAGE_NAME}
        """
      }
    }
  }

  post {
    success {
      echo "✅ Deploy thành công!"
    }
    failure {
      echo "❌ Có lỗi xảy ra trong quá trình deploy!"
    }
  }
}
