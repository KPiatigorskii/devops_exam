node{
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

        stage('Push to DockerHub'){
            sh 'docker login -u kpiatigorskii -p dckr_pat_6whSoke9x4b7XCwQjpztIE3QnOg'
            sh 'docker push kpiatigorskii/devops_exam'
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
        stage('Check'){
            check_count = sh (
                script: "curl -Is -m 3 ${ec2_instanse}:8089/todo | head -n 1 | grep -c '200 OK'",
                returnStdout: true
                )
            echo "CHECK COUNT: $check_count"
            if (check_count.toInteger() == 1 ){
                println "check was successful" 
            }
            else{
                println "check was unsuccessful"
                exit
            }
        }
    }
    catch(error){
        throw error
    }
    finally{
        stage('Notifications'){
            def currentBuildStatus = currentBuild.result
                if (currentBuildStatus == 'SUCCESS') {
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