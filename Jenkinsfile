node{
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

                ssh -o StrictHostKeyChecking=no ubuntu@${ec2_instanse} ' cd /home/ubuntu/devops_exam/ && sudo docker-compose down && sudo docker-compose up  -d --wait'
                """
                }
    }
    stage('Check'){
        check_count = sh (
            script: "curl -Is ${ec2_instanse} | head -n 1 | grep -c '200 OK'",
            returnStdout: true
            )
        echo "CHECK COUNT: $check_count"
    }

}