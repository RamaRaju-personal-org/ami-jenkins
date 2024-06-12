pipelineJob('docker-build-and-push') {
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('jenkins_ami_git_url')  // Replace with your GitHub repository URL
                        credentials('git-personal-access-token')
                    }
                    branch('*/main')
                }
            }
            scriptPath('jenkins/Jenkinsfile')
        }
    }
}
