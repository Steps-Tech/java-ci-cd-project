
## This code will send the email notification via Jenkins Pipeline to Gmail[Success/Failure]

## Gmail Settings
  * * Go to Manage Google Accounts
    * Go to Settings search for App Passwords
    * Create a App Password
    * Save it for future use

## Jenkins Setting
  * * Go to Manage Jenkins -- > System -- >
   
    ![image](https://github.com/user-attachments/assets/70ce50ff-ce5d-4ed0-adeb-20b8d5c0c939)

    * Fill the Above information correctly
    * Credentials : Add Credential add email address as username and Password should be app password which was created earlier.
   
    ## Within a Same Page Find E-mail notification

    ![image](https://github.com/user-attachments/assets/4bfd105f-ee49-45f3-9409-e1e04fe6da10)

    ![image](https://github.com/user-attachments/assets/e402f9e8-e792-42c8-b3b6-a0696ccb94d4)

    * * again password should be App Password not the console password.
     
  ## Now we are good to Deploy our email notification code in Jenkins Pipeline.

  ``` groovy
pipeline {
    agent any
    
    tools {
        maven "maven3"
        jdk "jdk17"
    }

    stages {
        stage (GitHub) {
            steps {
                git branch : 'main' , url: 'https://github.com/hkhcoder/vprofile-project.git'
            }
        }
    }
    
    post {
    success {
        script {
            def jobName = env.JOB_NAME
            def buildNumber = env.BUILD_NUMBER
            def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
            def bannerColor = pipelineStatus.toUpperCase() == 'BUILD IS SUCCESS' ? 'green' : 'red'

            def body = """
                <html>
                <body>
                <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                <h2>${jobName} - Build ${buildNumber}</h2>
                <div style="background-color: ${bannerColor}; padding: 10px;">
                <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                </div>
                <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                </div>
                </body>
                </html>
            """

            emailext (
                subject: "Build Success : ${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                body: body,
                to: 'praful.itankar@gmail.com',
                from: 'jenkins@example.com',
                replyTo: 'jenkins@example.com',
                mimeType: 'text/html',
                attachmentsPattern: 'trivy-image-report.html'
            )
        }
    }

    failure {
        script {
            def jobName = env.JOB_NAME
            def buildNumber = env.BUILD_NUMBER
            def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
            def bannerColor = pipelineStatus.toUpperCase() == 'BUILD is Failed' ? 'green' : 'red'

            def body = """
                <html>
                <body>
                <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                <h2>${jobName} - Build ${buildNumber}</h2>
                <div style="background-color: ${bannerColor}; padding: 10px;">
                <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                </div>
                <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                </div>
                </body>
                </html>
            """

            emailext (
                subject: "Build Failed : ${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                body: body,
                to: 'praful.itankar@gmail.com',
                from: 'jenkins@example.com',
                replyTo: 'jenkins@example.com',
                mimeType: 'text/html',
                attachmentsPattern: 'trivy-image-report.html'
            )
        }
    }
  }
}
```




