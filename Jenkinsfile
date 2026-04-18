pipeline {
    agent any
    tools {
        jdk 'jdk'
        nodejs 'node'
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
                withSonarQubeEnv('SonarQube') {
                    sh '''
                    $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectName=Hotstar \
                    -Dsonar.projectKey=Hotstar \
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
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DC'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Trivy FS Scan') {
            steps {
                script {
                    sh 'trivy fs --severity HIGH,CRITICAL ./ --format table --output trivy-fs-report.txt'
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'f5114f9a-f288-41dd-b185-f1a2479fcf59', toolName: 'docker') {
                        sh "docker build -t hotstar ."
                        sh 'docker tag hotstar vaibhavcheif/hotstar:latest'
                        sh 'docker push vaibhavcheif/hotstar:latest'
                    }
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                script {
                    sh 'trivy image --severity HIGH,CRITICAL --format table --output trivy-image-report.txt vaibhavcheif/hotstar:latest'
                }
            }
        }

        stage('Deploy Docker') {
            steps {
                sh "docker run --rm -d --name hotstar -p ${PORT}:3000 vaibhavcheif/hotstar:latest"
            }
        }
    }
}
