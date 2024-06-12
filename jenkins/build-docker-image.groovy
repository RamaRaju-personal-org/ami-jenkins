pipelineJob('StaticSitePipeline') {
    description('Pipeline job to build and push Docker image for static-site')
    triggers {
        scm('* * * * *') // Polling the SCM every minute (adjust as needed)
        githubPush()
    }
    definition {
        cps {
            script('''
pipeline {
    agent any 
    triggers {
        // Polling the SCM to detect changes
        pollSCM('* * * * *') // This configuration polls the SCM every minute (adjust as needed)
        // GitHub webhook trigger
        githubPush()
    }
    environment {
        GIT_REPO = 'https://github.com/RamaRaju-vj/static-site.git'
        GIT_BRANCH = 'main'
        GIT_CREDENTIALS_ID = 'git-personal-access-token'
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials-id')
    }
    stages {
        stage("Clean Workspace") {
            steps {
                cleanWs()
            }
        }

        stage("Clone static-site repo") {
            steps {
                echo "Cloning the repo"
                withCredentials([usernamePassword(credentialsId: "${GIT_CREDENTIALS_ID}", passwordVariable: 'GIT_TOKEN', usernameVariable: 'GIT_USERNAME')]) {
                    sh '''
                        git clone --branch ${GIT_BRANCH} https://${GIT_TOKEN}@github.com/RamaRaju-vj/static-site.git
                    '''
                }
            }
        }
        
        stage("Build the caddy image and push") {
            steps {
                echo "Building the image"
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials-id', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh '''
                        docker build -t ram2305/caddy:${BUILD_NUMBER} -f static-site/Dockerfile static-site
                        echo $PASS | docker login -u $USER --password-stdin
                        docker push ram2305/caddy:${BUILD_NUMBER}
                    '''
                }
            }
        }
    }
}
            '''.stripIndent())
            sandbox()
        }
    }
}
