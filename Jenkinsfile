pipeline {
    agent { label 'kvm-template-builder' }
    stages {
        stage('Build Nix overlay') {
            steps {
                sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                    'nix-build build.nix --cores 8 -A nixpkgsUnstable'
            }
        }
    }
    post {
        success { cleanWs() }
        failure { notifySlack "Build failled: ${JOB_NAME} [<${RUN_DISPLAY_URL}|${BUILD_NUMBER}>]", "red" }
    }
}
