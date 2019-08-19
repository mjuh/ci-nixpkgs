pipeline {
    agent { label 'kvm-template-builder' }
    stages {
        stage('Build PHP')
        {
            parallel {
                // stage('PHP 52') {
                //     steps {
                //         sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                //             'nix-build build.nix --keep-going -A nixpkgsUnstable.php52' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php52-dbase' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php52-imagick' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php52-intl' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php52-timezonedb' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php52-zendopcache' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php52-image' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php52-test'
                //     }
                // }
                // stage('PHP 53') {
                //     steps {
                //         sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                //             'nix-build build.nix --keep-going -A nixpkgsUnstable.php53' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php53-dbase' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php53-imagick' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php53-intl' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php53-timezonedb' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php53-zendopcache' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php53-image' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php53-test'
                //     }
                // }
                // stage('PHP 54') {
                //     steps {
                //         sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                //             'nix-build build.nix --keep-going -A nixpkgsUnstable.php54' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php54-imagick' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php54-memcached' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php54-redis' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php54-timezonedb' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php54-zendopcache' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php54-image' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php54-test'
                //     }
                // }
                // stage('PHP 55') {
                //     steps {
                //         sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                //             'nix-build build.nix --keep-going -A nixpkgsUnstable.php55' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php55-dbase' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php55-imagick' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php55-intl' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php55-timezonedb' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php55-image' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php55-test'
                //     }
                // }
                // stage('PHP 56') {
                //     steps {
                //         sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                //             'nix-build build.nix --keep-going -A nixpkgsUnstable.php56' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php56-dbase' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php56-imagick' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php56-intl' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php56-timezonedb' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php56-image' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php56-test'
                //     }
                // }
                stage('PHP 70') {
                    steps {
                        sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                            'nix-build build.nix --keep-going -A nixpkgsUnstable.php70' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php70-imagick' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php70-memcached' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php70-redis' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php70-rrd' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php70-timezonedb' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php70-image' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php70-test'
                    }
                }
                // stage('PHP 71') {
                //     steps {
                //         sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                //             'nix-build build.nix --keep-going -A nixpkgsUnstable.php71' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php71-imagick' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php71-memcached' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php71-redis' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php71-rrd' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php71-timezonedb' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php71-image' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php71-test'
                //     }
                // }
                // stage('PHP 72') {
                //     steps {
                //         sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                //             'nix-build build.nix --keep-going -A nixpkgsUnstable.php72' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php72-imagick' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php72-memcached' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php72-redis' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php72-rrd' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php72-timezonedb' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php72-image' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php72-test'
                //     }
                // }
                // stage('PHP 73') {
                //     steps {
                //         sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                //             'nix-build build.nix --keep-going -A nixpkgsUnstable.php73' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php73-imagick' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php73-memcached' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php73-redis' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php73-rrd' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php73-timezonedb' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php73-image' +
                //             '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php73-test'
                //     }
                // }
            }}
        // stage('Build overlay') {
        //     steps {
        //         sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
        //             'nix-build build.nix --cores 16 -A nixpkgsUnstable --keep-going --keep-failed'
        //     }
        // }
        // stage('Trigger jobs') {
        //     when { branch 'master' }
        //     steps {
        //           build '../apache2-php4/master'
        //           build '../apache2-php52/master'
        //           build '../apache2-php53/master'
        //           build '../apache2-php54/master'
        //           build '../apache2-php55/master'
        //           build '../apache2-php56/master'
        //           build '../apache2-php70/master'
        //           build '../apache2-php71/master'
        //           build '../apache2-php72/master'
        //           build '../apache2-php73/master'
        //           build '../postfix/master'
        //           build '../ftpserver/master'
        //     }
        // }
    }
    post {
        success { notifySlack "Build ${JOB_NAME} succeeded" , "green" }
        failure { notifySlack "Build failled: ${JOB_NAME} [<${RUN_DISPLAY_URL}|${BUILD_NUMBER}>]", "red" }
    }
}
