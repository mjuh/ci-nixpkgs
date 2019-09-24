pipeline {
    agent { label 'nixbld' }
    stages {
        stage('Build overlay') {
            steps {
                sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                    'nix-build build.nix --no-build-output --cores 16 --keep-failed'
            }
        }
        stage('Trigger jobs') {
            when { branch 'master' }
            steps {
                build '../ssh-guest-room/master'
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
        success { notifySlack "Build ${JOB_NAME} succeeded" , "green" }
        failure { notifySlack "Build failled: ${JOB_NAME} [<${RUN_DISPLAY_URL}|${BUILD_NUMBER}>]", "red" }
    }
}
