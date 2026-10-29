pipeline {

    agent any

    environment {
        PATH = "/Users/midhtech_02/.docker/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:${env.PATH}"

        HARBOR_REGISTRY = "localhost:8082"
        HARBOR_PROJECT  = "claims"

        VAULT_ADDR = "http://127.0.0.1:8200"

        UC15_CHART       = "usecase-15/chart"
        UC15_VALUES      = "usecase-15/values"
        UC15_ARGOCD_APPS = "usecase-15/argocd"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Code checked out from GitLab'
                sh '''
                    echo "Branch: $(git branch --show-current)"
                    echo "Commit: $(git rev-parse HEAD)"
                '''
            }
        }

        stage('Backend Dependencies') {
            steps {
                sh '''
                    set -e

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
                withCredentials([
                    string(
                        credentialsId: 'claims-db-password',
                        variable: 'DB_PASSWORD'
                    )
                ]) {
                    sh '''
                        set -e

                        cd backend
                        . venv/bin/activate

                        export DB_HOST=localhost
                        export DB_NAME=claimsdb
                        export DB_USER=claimsuser
                        export DB_PORT=5432

                        pytest -v
                    '''
                }
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

        stage('Check Docker, Trivy, Helm, Vault and Argo CD') {
            steps {
                sh '''
                    set -e

                    echo "=== Docker ==="
                    docker --version

                    echo "=== Trivy ==="
                    trivy --version

                    echo "=== Helm ==="
                    helm version --short

                    echo "=== kubectl ==="
                    kubectl version --client

                    echo "=== Vault ==="
                    vault version

                    echo "=== Argo CD ==="
                    argocd version --client
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    set -e

                    echo "Building backend image"
                    docker build \
                      -t claims-backend:test \
                      ./backend

                    echo "Building frontend image"
                    docker build \
                      -t claims-frontend:test \
                      ./frontend
                '''
            }
        }

        stage('Trivy Scan - Backend') {
            steps {
                sh '''
                    set -e

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
                    set -e

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
                    set -e

                    docker tag \
                      claims-backend:test \
                      claims-backend:${GIT_SHA}

                    docker tag \
                      claims-frontend:test \
                      claims-frontend:${GIT_SHA}
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
                        set -e

                        echo "$HARBOR_PASSWORD" |
                        docker login \
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
                    set -e

                    docker tag \
                      claims-backend:${GIT_SHA} \
                      ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/claims-backend:${GIT_SHA}

                    docker tag \
                      claims-frontend:${GIT_SHA} \
                      ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/claims-frontend:${GIT_SHA}
                '''
            }
        }

        stage('Push Images to Harbor') {
            steps {
                sh '''
                    set -e

                    docker push \
                      ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/claims-backend:${GIT_SHA}

                    docker push \
                      ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/claims-frontend:${GIT_SHA}
                '''
            }
        }

        stage('Record Image Digests') {
            steps {
                script {
                    env.BACKEND_IMAGE_DIGEST = sh(
                        script: """
                            docker inspect \
                              --format='{{index .RepoDigests 0}}' \
                              ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/claims-backend:${GIT_SHA}
                        """,
                        returnStdout: true
                    ).trim()

                    env.FRONTEND_IMAGE_DIGEST = sh(
                        script: """
                            docker inspect \
                              --format='{{index .RepoDigests 0}}' \
                              ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/claims-frontend:${GIT_SHA}
                        """,
                        returnStdout: true
                    ).trim()

                    echo "Backend digest recorded"
                    echo "Frontend digest recorded"
                }
            }
        }

        stage('Verify Images') {
            steps {
                sh '''
                    set -e

                    echo "=== Backend images ==="
                    docker images claims-backend

                    echo "=== Frontend images ==="
                    docker images claims-frontend

                    echo "=== Harbor backend images ==="
                    docker images \
                      ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/claims-backend

                    echo "=== Harbor frontend images ==="
                    docker images \
                      ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/claims-frontend
                '''
            }
        }

        /*
         * USE CASE 15 STARTS HERE
         */

        stage('UC15 - Validate Required Files') {
            steps {
                sh '''
                    set -e

                    test -d "$UC15_CHART"
                    test -d "$UC15_VALUES"

                    test -f "$UC15_VALUES/values-common.yaml"
                    test -f "$UC15_VALUES/values-dev.yaml"
                    test -f "$UC15_VALUES/values-qa.yaml"
                    test -f "$UC15_VALUES/values-stage.yaml"
                    test -f "$UC15_VALUES/values-prod.yaml"

                    echo "PASS: All Use Case 15 files exist"
                '''
            }
        }

        stage('UC15 - Validate Helm Environments') {
            steps {
                sh '''
                    set -e

                    for ENVIRONMENT in dev qa stage prod
                    do
                        echo "======================================"
                        echo "Validating environment: ${ENVIRONMENT}"
                        echo "======================================"

                        helm lint "$UC15_CHART" \
                          -f "$UC15_VALUES/values-common.yaml" \
                          -f "$UC15_VALUES/values-${ENVIRONMENT}.yaml"

                        helm template usecase15-demo \
                          "$UC15_CHART" \
                          -f "$UC15_VALUES/values-common.yaml" \
                          -f "$UC15_VALUES/values-${ENVIRONMENT}.yaml" \
                          > "/tmp/usecase15-${ENVIRONMENT}.yaml"

                        test -s "/tmp/usecase15-${ENVIRONMENT}.yaml"
                    done

                    echo "PASS: All four environments rendered successfully"
                '''
            }
        }

        stage('UC15 - Verify Immutable Image') {
            steps {
                sh '''
                    set -e

                    IMAGE_REFERENCE=$(awk '
                      /reference:/ {
                        gsub(/"/, "", $2)
                        print $2
                      }
                    ' "$UC15_VALUES/values-common.yaml")

                    echo "Configured image: ${IMAGE_REFERENCE}"

                    case "$IMAGE_REFERENCE" in
                        *@sha256:*)
                            echo "PASS: Immutable SHA256 image configured"
                            ;;
                        *)
                            echo "FAIL: Image must use an immutable digest"
                            exit 1
                            ;;
                    esac
                '''
            }
        }

        stage('UC15 - Verify Secret References') {
            steps {
                sh '''
                    set -e

                    for ENVIRONMENT in dev qa stage prod
                    do
                        EXPECTED_SECRET="claims-${ENVIRONMENT}-secret"

                        echo "Checking ${ENVIRONMENT}"
                        echo "Expected Secret: ${EXPECTED_SECRET}"

                        grep -q \
                          "secretName: ${EXPECTED_SECRET}" \
                          "$UC15_VALUES/values-${ENVIRONMENT}.yaml"
                    done

                    echo "PASS: Environment Secret references are isolated"
                '''
            }
        }

        stage('UC15 - Verify Vault Secret Paths') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'vault-token',
                        variable: 'VAULT_TOKEN'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "Checking Vault metadata only"
                        echo "Raw secret values will not be printed"

                        vault kv metadata get \
                          -mount=secret \
                          claims/dev >/dev/null

                        vault kv metadata get \
                          -mount=secret \
                          claims/qa >/dev/null

                        vault kv metadata get \
                          -mount=secret \
                          claims/stage >/dev/null

                        vault kv metadata get \
                          -mount=secret \
                          claims/prod >/dev/null

                        echo "PASS: All four Vault paths exist"
                    '''
                }
            }
        }

        stage('UC15 - Register Argo CD Applications') {
            steps {
                sh '''
                    set -e

                    test -d "$UC15_ARGOCD_APPS"

                    kubectl apply \
                      -f "$UC15_ARGOCD_APPS"

                    echo "Argo CD Applications registered"
                '''
            }
        }

        stage('UC15 - Sync Dev') {
            steps {
                sh '''
                    set -e

                    argocd app sync \
                      usecase15-dev \
                      --core

                    argocd app wait \
                      usecase15-dev \
                      --core \
                      --sync \
                      --health \
                      --timeout 180
                '''
            }
        }

        stage('UC15 - Sync QA') {
            steps {
                sh '''
                    set -e

                    argocd app sync \
                      usecase15-qa \
                      --core

                    argocd app wait \
                      usecase15-qa \
                      --core \
                      --sync \
                      --health \
                      --timeout 180
                '''
            }
        }

        stage('UC15 - Approve Stage Promotion') {
            input {
                message "Dev and QA completed. Approve promotion to Stage?"
                ok "Promote to Stage"
                submitter "midhtech_02"
                submitterParameter "STAGE_APPROVER"
            }

            steps {
                echo "Stage promotion approved by ${STAGE_APPROVER}"
            }
        }

        stage('UC15 - Sync Stage') {
            steps {
                sh '''
                    set -e

                    argocd app sync \
                      usecase15-stage \
                      --core

                    argocd app wait \
                      usecase15-stage \
                      --core \
                      --sync \
                      --health \
                      --timeout 180
                '''
            }
        }

        stage('UC15 - Approve Production Promotion') {
            input {
                message "Stage completed. Approve promotion to Production?"
                ok "Promote to Production"
                submitter "midhtech_02"
                submitterParameter "PROD_APPROVER"
            }

            steps {
                echo "Production promotion approved by ${PROD_APPROVER}"
            }
        }

        stage('UC15 - Sync Production') {
            steps {
                sh '''
                    set -e

                    argocd app sync \
                      usecase15-prod \
                      --core

                    argocd app wait \
                      usecase15-prod \
                      --core \
                      --sync \
                      --health \
                      --timeout 180
                '''
            }
        }

        stage('UC15 - Verify Four Environments') {
            steps {
                sh '''
                    set -e

                    for NAMESPACE in \
                      claims-dev \
                      claims-qa \
                      claims-stage \
                      claims-prod
                    do
                        echo
                        echo "======================================"
                        echo "Namespace: ${NAMESPACE}"
                        echo "======================================"

                        kubectl get deployment,pods,service \
                          -n "${NAMESPACE}" \
                          -o wide
                    done
                '''
            }
        }

        stage('UC15 - Compare Image Digests') {
            steps {
                sh '''
                    set -e

                    EXPECTED_IMAGE=""

                    for NAMESPACE in \
                      claims-dev \
                      claims-qa \
                      claims-stage \
                      claims-prod
                    do
                        CURRENT_IMAGE=$(kubectl get deployment \
                          usecase15-demo \
                          -n "${NAMESPACE}" \
                          -o jsonpath='{.spec.template.spec.containers[0].image}')

                        echo "${NAMESPACE}: ${CURRENT_IMAGE}"

                        if [ -z "$EXPECTED_IMAGE" ]
                        then
                            EXPECTED_IMAGE="$CURRENT_IMAGE"
                        elif [ "$EXPECTED_IMAGE" != "$CURRENT_IMAGE" ]
                        then
                            echo "FAIL: Image differs in ${NAMESPACE}"
                            exit 1
                        fi
                    done

                    case "$EXPECTED_IMAGE" in
                        *@sha256:*)
                            echo "PASS: All environments use the same immutable digest"
                            ;;
                        *)
                            echo "FAIL: Deployed image is not immutable"
                            exit 1
                            ;;
                    esac
                '''
            }
        }

        stage('UC15 - Final Argo CD Status') {
            steps {
                sh '''
                    set -e

                    for APPLICATION in \
                      usecase15-dev \
                      usecase15-qa \
                      usecase15-stage \
                      usecase15-prod
                    do
                        echo
                        echo "=== ${APPLICATION} ==="

                        argocd app get \
                          "${APPLICATION}" \
                          --core
                    done
                '''
            }
        }
    }

    post {

        success {
            echo 'Pipeline completed successfully.'
            echo 'Use Case 15 multi-environment promotion completed.'
            echo 'Dev, QA, Stage and Production are synchronized and healthy.'
        }

        failure {
            echo 'Pipeline failed.'
            echo 'Check the failed stage in Jenkins Console Output.'
        }

        aborted {
            echo 'Pipeline was aborted or an approval was rejected.'
        }

        always {
            sh '''
                docker logout "$HARBOR_REGISTRY" >/dev/null 2>&1 || true
            '''

            echo 'Pipeline execution finished.'
        }
    }
}