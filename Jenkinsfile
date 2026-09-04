pipeline {
    agent any

    environment {
        PATH = "/Users/midhtech_02/.docker/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:${env.PATH}"
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
        stage('Quality Gate') {
    steps {
        timeout(time: 2, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}

        stage('Check Docker and Trivy') {
            steps {
                sh '''
                    echo "Checking Docker..."
                    docker --version

                    echo "Checking Trivy..."
                    trivy --version
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    echo "Building backend image..."
                    docker build -t claims-backend:test ./backend

                    echo "Building frontend image..."
                    docker build -t claims-frontend:test ./frontend
                '''
            }
        }

        stage('Trivy Scan - Backend') {
            steps {
                sh '''
                    echo "Scanning backend image..."

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
                    echo "Scanning frontend image..."

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

                    echo "Current Git SHA: ${env.GIT_SHA}"
                }

                sh '''
                    docker tag \
                      claims-backend:test \
                      claims-backend:${GIT_SHA}

                    docker tag \
                      claims-frontend:test \
                      claims-frontend:${GIT_SHA}

                    echo "Docker images tagged with Git SHA: ${GIT_SHA}"
                '''
            }
        }

        stage('Verify Images') {
            steps {
                sh '''
                    echo "Backend image:"
                    docker images claims-backend

                    echo "Frontend image:"
                    docker images claims-frontend
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully'
            echo 'Build, test, SonarQube analysis, Docker build, Trivy scan and image tagging completed.'
        }

        failure {
            echo 'Pipeline failed. Check the failed stage in Console Output.'
        }

        always {
            echo 'Pipeline execution finished.'
        }
    }
}