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
            when { branch 'master' }
            steps {
                  build '../apache2-php4/master'
                  build '../apache2-php52/master'
                  build '../apache2-php53/master'
                  build '../apache2-php54/master'
                  build '../apache2-php55/master'
                  build '../apache2-php56/master'
                  build '../apache2-php70/master'
                  build '../apache2-php71/master'
                  build '../apache2-php72/master'
                  build '../apache2-php73/master'
                  build '../postfix/master'
                  build '../ftpserver/master'
            }
        }
    }
    post {
        success { cleanWs() }
        failure { notifySlack "Build failled: ${JOB_NAME} [<${RUN_DISPLAY_URL}|${BUILD_NUMBER}>] at stage ${STAGE_NAME}", "red" }
    }
}
