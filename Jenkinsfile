pipeline {
    agent any

    environment {
        APP_NAME = 'churn-api'
        NAMESPACE = 'mlops'
        IMAGE_NAME = 'your-docker-username/mlops-churn'
        IMAGE_TAG = 'latest'
        CONTAINER_PORT = '8000'
        SERVICE_PORT = '80'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup Environment') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }

        stage('Generate Data') {
            steps {
                sh 'python generate_data.py'
            }
        }

        stage('Train Model') {
            steps {
                sh 'python train.py'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${env.IMAGE_NAME}:${env.IMAGE_TAG} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                sh "docker push ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'chmod +x deploy.sh'
                sh './deploy.sh'
            }
        }
    }

    post {
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}