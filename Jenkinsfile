pipeline {
    agent any

    parameters {
        booleanParam(name: 'SKIP_TRIVY', defaultValue: false, description: 'Skip Trivy scans?')
        booleanParam(name: 'SKIP_OWASP', defaultValue: false, description: 'Skip OWASP Dependency Check?')
    }

    tools {
        jdk 'jdk21'
        nodejs 'node16'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        PORT = '3000'
    }

    stages {
        stage('Git checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/vaibhavcheif/Devsecops-Hotstar-Clone.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''
                    $SCANNER_HOME/bin/sonar-scanner \
                      -Dsonar.projectName=Hotstar \
                      -Dsonar.projectKey=Hotstar-clone1 \
                      -Dsonar.projectVersion=1.0 \
                      -Dsonar.sources=.
                    '''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }

        stage('OWASP FS SCAN') {
            when {
                expression { return !params.SKIP_OWASP }
            }
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Trivy FS Scan') {
            when {
                expression { return !params.SKIP_TRIVY }
            }
            steps {
                sh 'trivy fs --severity HIGH,CRITICAL ./ --format table --output trivy-fs-report.txt'
            }
        }

        stage('Docker Build and Docker Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh "docker build -t hotstar ."
                        sh 'docker tag hotstar vaibhavcheif/hotstar:latest'
                        sh 'docker push vaibhavcheif/hotstar:latest'
                    }
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh 'trivy image --severity HIGH,CRITICAL --format table --output trivy-image-report.txt vaibhavcheif/hotstar:latest'
            }
        }

        stage('Deploy Docker') {
            steps {
                  sh '''
                  docker rm -f hotstar || true
                  docker run -d --name hotstar -p ${PORT}:3000 vaibhavcheif/hotstar:latest
                  '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    dir('K8S') {
                        withKubeConfig(
                            credentialsId: 'k8s',
                            serverUrl: 'https://017F83AAA75335EC5BC0D341A11F27B9.gr7.ap-south-1.eks.amazonaws.com',
                            namespace: 'default'
                        ) {
                            sh 'kubectl apply -f deployment.yml'
                            sh 'kubectl apply -f service.yml'
                        }
                    }
                }
            }
        }
    }
}
