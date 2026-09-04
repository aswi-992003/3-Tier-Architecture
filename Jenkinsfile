pipeline {
    agent any

    environment {
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:${env.PATH}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Code checked out from GitLab'
            }
        }

        stage('Backend Dependencies') {
            steps {
                sh '''
                    cd backend
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                sh '''
                    cd backend
                    . venv/bin/activate
                    pytest -v
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'

                    withSonarQubeEnv('SonarQube') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=3-tier-architecture \
                            -Dsonar.projectName=3-tier-architecture \
                            -Dsonar.sources=. \
                            -Dsonar.exclusions=backend/venv/**,frontend/node_modules/**,frontend/dist/**
                        """
                    }
                }
            }
        }

        stage('Check Docker and Trivy') {
            steps {
                sh '''
                    docker --version
                    trivy --version
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build --no-cache -t claims-backend:test ./backend
                    docker build --no-cache -t claims-frontend:test ./frontend
                '''
            }
        }

        stage('Trivy Scan - Backend') {
            steps {
                sh '''
                    trivy image \
                      --scanners vuln \
                      --severity HIGH,CRITICAL \
                      --ignore-unfixed \
                      --exit-code 1 \
                      claims-backend:test
                '''
            }
        }

        stage('Trivy Scan - Frontend') {
            steps {
                sh '''
                    trivy image \
                      --scanners vuln \
                      --severity HIGH,CRITICAL \
                      --ignore-unfixed \
                      --exit-code 1 \
                      claims-frontend:test
                '''
            }
        }

        stage('Tag Images with Git SHA') {
            steps {
                script {
                    env.GIT_SHA = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                }

                sh '''
                    docker tag claims-backend:test claims-backend:${GIT_SHA}
                    docker tag claims-frontend:test claims-frontend:${GIT_SHA}
                '''

                echo "Images tagged with Git SHA: ${env.GIT_SHA}"
            }
        }

    }

    post {
        success {
            echo 'Pipeline completed successfully'
        }

        failure {
            echo 'Pipeline failed. Check the console output.'
        }

        always {
            echo 'Pipeline execution finished'
        }
    }
}
