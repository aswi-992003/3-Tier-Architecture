pipeline {

    agent any

    environment {
        PATH = "/Users/midhtech_02/.docker/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:${env.PATH}"

        HARBOR_REGISTRY = "localhost:8082"
        HARBOR_PROJECT = "claims"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Code checked out from GitLab'
                echo 'Jenkins pipeline triggered successfully after Jenkinsfile update'
                echo 'Jenkins pipeline triggered successfully after Jenkinsfile update'

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

        stage('Harbor Login') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'harbor-credentials',
                        usernameVariable: 'HARBOR_USER',
                        passwordVariable: 'HARBOR_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$HARBOR_PASSWORD" | docker login \
                          "$HARBOR_REGISTRY" \
                          -u "$HARBOR_USER" \
                          --password-stdin
                    '''
                }
            }
        }

        stage('Tag Images for Harbor') {
            steps {
                sh '''
                    echo "Tagging backend image for Harbor..."

                    docker tag \
                      claims-backend:${GIT_SHA} \
                      ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/claims-backend:${GIT_SHA}

                    echo "Tagging frontend image for Harbor..."

                    docker tag \
                      claims-frontend:${GIT_SHA} \
                      ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/claims-frontend:${GIT_SHA}
                '''
            }
        }

        stage('Push Images to Harbor') {
            steps {
                sh '''
                    echo "Pushing backend image to Harbor..."

                    docker push \
                      ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/claims-backend:${GIT_SHA}

                    echo "Pushing frontend image to Harbor..."

                    docker push \
                      ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/claims-frontend:${GIT_SHA}
                '''
            }
        }

        stage('Record Image Digests') {
            steps {
                sh '''
                    echo "Backend image digest:"

                    docker inspect \
                      --format='{{index .RepoDigests 0}}' \
                      ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/claims-backend:${GIT_SHA}

                    echo "Frontend image digest:"

                    docker inspect \
                      --format='{{index .RepoDigests 0}}' \
                      ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/claims-frontend:${GIT_SHA}
                '''
            }
        }

        stage('Verify Images') {
            steps {
                sh '''
                    echo "Backend local images:"
                    docker images claims-backend

                    echo "Frontend local images:"
                    docker images claims-frontend

                    echo "Harbor backend image:"
                    docker images ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/claims-backend

                    echo "Harbor frontend image:"
                    docker images ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/claims-frontend
                '''
            }
        }
    }

    post {

        success {
            echo 'Pipeline completed successfully'
            echo 'Build, test, SonarQube, Quality Gate, Docker build, Trivy scan, Git SHA tagging and Harbor push completed.'
        }

        failure {
            echo 'Pipeline failed. Check the failed stage in Console Output.'
        }

        always {
            echo 'Pipeline execution finished.'
        }
    }
}