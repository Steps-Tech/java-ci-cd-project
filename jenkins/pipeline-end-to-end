pipeline {
    agent any
    tools {
        maven  "MAVEN3"
        jdk  "Oracle11"
    }
    
    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub' // Jenkins credentials ID for Docker Hub
        DOCKER_IMAGE_NAME = 'stepstech/devops-weekend'
        DOCKER_TAG = 'Revision-1.7' // You can use versioning or a unique tag as needed
        //DOCKER_HOST = '172.31.72.40'
        registry = "devops-weekend"
        CONTAINER_NAME = "webapp-${env.BUILD_ID}"
        
    }

    stages {
        stage ('Fetching code') {
            steps {
                git branch : 'main' , url: 'https://github.com/hkhcoder/vprofile-project.git'
            }
        }

        stage ('Source code build'){
            steps {
                sh 'mvn install -DskipTests'  
            }

            post {
            success {  
                echo 'Archieving the Artifact'
                archiveArtifacts artifacts: '**/*.war'
            }
          }
        }

        stage ('Unit Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage ('Checkstyle Analysis'){
            steps {
                sh 'mvn checkstyle:checkstyle'
            }

        }

        stage ('Sonar Scanner') {
            environment {
                scannerHome = tool 'Sonar4.7'
            }
            steps {
                withSonarQubeEnv('Sonar') {
                    sh '''${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=vprofile \
                        -Dsonar.projectName=vprofile \
                        -Dsonar.projectVersion=1.0 \
                        -Dsonar.sources=src/ \
                        -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest  \
                        -Dsonar.junit.reportPaths=target/surefire-reports/ \
                        -Dsonar.jacoco.reportPaths=target/jacoco.exec \
                        -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                }
            }    
        }
        stage ("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                  waitForQualityGate abortPipeline: true
              }
            }
          }

        stage ("Artifact Uploader"){
            steps {
                nexusArtifactUploader(
                nexusVersion: 'nexus3',
                protocol: 'http',
                nexusUrl: '172.31.43.127:8081', // Do not use http here and we also use Private Ip of Nexus Server
                groupId: 'Test', // this is mendatory and value can be optional
                version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}", //Enable  BUILD_TIMESTAMP from System
                repository: 'vproject',
                credentialsId: 'nexuslogin',
                artifacts: [
                    [artifactId: 'vproapp',
                    classifier: '',
                    file: 'target/vprofile-v2.war',
                    type: 'war']
                ]
             )
            }
        }
        
        stage('Build Docker Image') {
            steps {
                dir('/var/lib/jenkins/workspace'){
                script {
                    // Build the Docker image
                    docker.build("${DOCKER_IMAGE_NAME}:${DOCKER_TAG}")
                }
              }
            }
        }
        
        stage('Login to Docker Hub') {
            steps {
                script {
                    // Login to Docker Hub
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        echo 'Logged in to Docker Hub'
                    }
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                script {
                    // Push the Docker image to Docker Hub
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        docker.image("${DOCKER_IMAGE_NAME}:${DOCKER_TAG}").push("${DOCKER_TAG}")
                        echo 'Docker Image Successfully Pushed to Docker Hub'
                    }
                }
            }
        }
        
        stage('Pull Docker Image on Remote Docker host') {
          steps {
            sshagent(['jenkins-docker-intergation']) { 
                sh "ssh -o StrictHostKeyChecking=no -l ubuntu 172.31.72.40  'docker pull $DOCKER_IMAGE_NAME:$DOCKER_TAG'"
                // jenkins-docker-intergation : add credential to connect docker host using Username with Private SSH key
                echo 'Docker Image Pulled on Remote Docker Host Successfully'
            }
         }
      }
        stage('Scan Docker Image by Trivy') {
          steps {
              sshagent(['jenkins-docker-intergation']) { 
                  sh "ssh -o StrictHostKeyChecking=no -l ubuntu 172.31.72.40  'trivy image $DOCKER_IMAGE_NAME:$DOCKER_TAG'"
                // jenkins-docker-intergation : add credential to connect docker host using Username with Private SSH key
                  echo 'Docker Image Scanned Successfully'
            }
         }
      }
      
        stage('Build Docker Container on Remote Host') {
            steps {
                sshagent(['jenkins-docker-intergation']) {
                    // Run Docker container from image
                    //docker.image("${DOCKER_IMAGE_NAME}").run('-d -p 8006:8080 --name ${CONTAINER_NAME}') // Example run options: detached mode, port mapping
                    sh "ssh -o StrictHostKeyChecking=no -l ubuntu 172.31.72.40 'docker run -itd --name $CONTAINER_NAME -p 8017:8080 $DOCKER_IMAGE_NAME:$DOCKER_TAG'"
                    echo 'Docker Container Successfully run on Remote Docker Host'
                }
            }
        }
        
   
    }
    
        post {
            success {
                echo 'Dockerised Application Deployed Successfully!'
        }
            failure {
                echo 'There was an issue with building Dockerised Application.'
        }
    }
}
