node{
    def allStagesSuccessful = true
    try{
        stage('Checkout') {
            git \
            credentialsId: 'github-creds', \
            url: 'https://github.com/KPiatigorskii/devops_exam.git', \
            branch: 'master'
        }

        stage('Build and Test'){
            sh 'docker build . -t kpiatigorskii/devops_exam'
        }
        stage("Check vulnerabilities"){
            sh 'trivy image kpiatigorskii/devops_exam'
        }
        stage('Push to DockerHub'){
            withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {                
                sh "docker login -u $USERNAME -p $PASSWORD"
                sh "docker push kpiatigorskii/devops_exam"
            }
        }

        stage('Deploy to EC2'){
            //ssh -o StrictHostKeyChecking=no ubuntu@${ec2_instanse} 'sudo docker login -u kpiatigorskii -p dckr_pat_6whSoke9x4b7XCwQjpztIE3QnOg'
                sshagent(['my-creds']) {

                    sh """
                    echo "${WORKSPACE}"
                    ls -l
                    ssh -o StrictHostKeyChecking=no ubuntu@${ec2_instanse} "rm -rf /home/ubuntu/devops_exam/docker-compose.yml"
                    scp -o StrictHostKeyChecking=no ${WORKSPACE}/docker-compose.yml  ubuntu@${ec2_instanse}:/home/ubuntu/devops_exam/docker-compose.yml

                    ssh -o StrictHostKeyChecking=no ubuntu@${ec2_instanse} ' cd /home/ubuntu/devops_exam/ && sudo docker-compose down && sudo docker-compose up  -d'
                    """
                    }
        }
        stage('Healthcheck'){
            checkCount = sh (
                script: "curl -Is -m 3 ${ec2_instanse}:8089/todo | head -n 1 | grep -c '200 OK'",
                returnStdout: true
                )
            if (checkCount.toInteger() == 1 ){
                println "check was successful" 
            }
            else{
                println "check was unsuccessful"
                exit
            }
        }

    }
    catch(error){
        println "throw error from try catch"
        allStagesSuccessful = false
        throw error
    }
    finally{
        stage('Notifications'){
                if (allStagesSuccessful) {
                    println "send success message" 
                    slackSend(
                        color: "#00FF00",
                        channel: "jenkins-notify",
                        message: "${currentBuild.fullDisplayName} succeeded",
                        tokenCredentialId: 'slack-token'
                    )
                } else {
                    println "send unsuccess message" 
                    slackSend(
                        color: "#FF0000",
                        channel: "jenkins-notify",
                        message: "${currentBuild.fullDisplayName} was failed",
                        tokenCredentialId: 'slack-token'
                    )
                }
        }
    }
}