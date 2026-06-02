pipeline {
    agent any

    // 1. Tell Jenkins to use your managed Maven installation
    tools {
        maven 'M3916' // Must exactly match the Name in Manage Jenkins -> Tools
    }
    environment {
        // Replace with your actual Docker Hub username
        DOCKER_HUB_USER = 'your_dockerhub_username'
        IMAGE_NAME      = 'simple-java-app'
        IMAGE_TAG       = "${BUILD_NUMBER}"
        REGISTRY_CREDS  = 'dockerhub-creds' // The Jenkins credential ID
    }

    stages {
        stage('Clone Source') {
            steps {
                // This step automatically clones the repo configured in the Jenkins Job
                checkout scm
            }
        }

        stage('Build App') {
            steps {
                echo 'Building Java Application using Maven...'
                // Using the Maven wrapper if present, otherwise use 'mvn.'
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
            echo 'Running Unit Tests...'
            sh 'mvn test'       // ✅ Use system Maven
        }
    }

        stage('Build Image') {
            steps {
                echo 'Building Docker Image...'
                script {
                    // Builds the image tagged as username/repo:build_number
                    dockerImage = docker.build("${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push Docker Hub') {
            steps {
                echo 'Pushing Image to Docker Hub...'
                script {
                    // Authenticates using Jenkins credentials and pushes the image
                    docker.withRegistry('https://index.docker.io/v1/', REGISTRY_CREDS) {
                        dockerImage.push()
                        dockerImage.push("latest") // Also tag and push as latest
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying Application...'
                // Example deployment: restarting a local docker-compose service or container
                // sh 'docker compose up -d --build'
                sh "echo 'Successfully deployed version ${IMAGE_TAG}'"
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
