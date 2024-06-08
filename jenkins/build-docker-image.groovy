pipelineJob('static-site-build-and-deploy') {
    definition {
        cps {
            script('''
pipeline {
    agent any 
    environment {
        GIT_REPO = 'git_static_site_repo_url'
        GIT_BRANCH = 'main'
        GIT_CREDENTIALS_ID = 'github-credentials-id'
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials-id')
    }
    stages {
        stage("Clean Workspace") {
            steps {
                cleanWs()
            }
        }

        stage("clone static-site repo") {
            steps {
                echo "cloning the repo"
                withCredentials([string(credentialsId: "${GIT_CREDENTIALS_ID}", variable: 'GIT_TOKEN')]) {
                    sh '''
                        git config --global credential.helper cache
                        git config --global url.https://${GIT_TOKEN}@github.com/.insteadOf https://github.com/
                        git clone --branch ${GIT_BRANCH} ${GIT_REPO}
                    '''
                }
            }
        }
        
        stage("build the caddy image and push") {
            steps {
                echo "building the image"
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials-id', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh '''
                        docker build -t ram2305/caddy:3.0 -f static-site/Dockerfile static-site
                        docker login -u $USER -p $PASS
                        docker push ram2305/caddy:3.0
                    '''
                }
            }
        }
    }
}
            ''')
        }
    }
}
