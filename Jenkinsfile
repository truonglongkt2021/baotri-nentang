pipeline {
  agent any

  environment {
    IMAGE_NAME = 'odoo-custom:latest'
    CONTAINER_NAME = 'odoo_app_jenkins'

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
}
