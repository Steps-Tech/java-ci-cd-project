pipeline {
    agent any
    tools {
        maven  "MAVEN3"
        jdk  "Oracle11"
    }

    environment {
	registry = "devops-weekend"  //DockerHub Regisrty name
	registryCredential = 'dockerhubnew' //Credential to connect with DOckerHub
        DOCKER_IMAGE = 'stepstech/devops-weekend:latest' //Docker Image should be available in DockerHub
        CONTAINER_NAME = 'webapp2' //Container name which will be created 
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
                scannerHome = tool 'Sonar4.7'  //Name should be match in Tools section of Jenkins
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

        stage ("upload artifact") {
            steps{
                nexusArtifactUploader(
                nexusVersion: 'nexus3',
                protocol: 'http',
                nexusUrl: '172.31.0.170:8081',
                groupId: 'Test',
                version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                repository: 'vproject',   // Repo Name of Nexus 
                credentialsId: 'nexuslogin',  //Id which shoud be match with Credential Section
                artifacts: [
                    [artifactId: 'vproapp',
                    classifier: '',
                    file: 'target/vprofile-v2.war',
                    type: 'war']
                ]
             )
            }
        }

        stage('Pull Docker Image') {
            steps {
                script {
                    // Pull Docker image
                    docker.image("${DOCKER_IMAGE}").pull()
                }
            }
        }

        stage('Build Docker Container') {
            steps {
                script {
                    // Run Docker container from image
                    docker.image("${DOCKER_IMAGE}").run('-d -p 8006:8080 --name ${CONTAINER_NAME}') // Example run options: detached mode, port mapping
                }
            }
        }
    }
}
