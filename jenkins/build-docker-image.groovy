pipelineJob('docker-build-and-push') {
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('jenkins_ami_git_url')  // Replace with your GitHub repository URL
                        credentials('github-credentials-id')
                    }
                    branch('*/main')
                }
            }
            scriptPath('jenkins/Jenkinsfile')
        }
    }
}
