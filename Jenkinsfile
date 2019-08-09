pipeline {
    agent { label 'kvm-template-builder' }
    stages {
        stage('Build Nix overlay') {
            steps {
                sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                    'nix-build build.nix --cores 16 -A nixpkgsUnstable --keep-going --keep-failed'
            }
        }
        stage('Rebuild all') {
            steps {
               if (env.BRANCH_NAME == 'master') {
                  build '../apache2-php4/master'
               }
            }
        }
    }
    post {
        success { cleanWs() }
        failure { notifySlack "Build failled: ${JOB_NAME} [<${RUN_DISPLAY_URL}|${BUILD_NUMBER}>]", "red" }
    }
}
