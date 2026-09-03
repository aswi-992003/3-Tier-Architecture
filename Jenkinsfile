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
    }

    post {
        success {
            echo 'Pipeline completed successfully'
        }

        failure {
            echo 'Pipeline failed. Check the console output.'
        }
    }
}