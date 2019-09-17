pipeline {
    agent { label 'nixbld' }
    stages {
        stage('PHP 52') {
            steps {
                script {
                    try {
                        sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                            'nix-build build.nix --keep-going -A nixpkgsUnstable.php52' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php52-dbase' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php52-imagick' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php52-intl' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php52-timezonedb' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php52-zendopcache' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php52-image' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php52-test --out-link result-php52'
                    }
                    catch (exception) {
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
        stage('PHP 53') {
            steps {
                script {
                    try {
                        sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                            'nix-build build.nix --keep-going -A nixpkgsUnstable.php53' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php53-dbase' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php53-imagick' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php53-intl' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php53-timezonedb' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php53-zendopcache' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php53-image' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php53-test --out-link result-php53'
                    }
                    catch (exception) {
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
        stage('PHP 54') {
            steps {
                script {
                    try {
                        sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                            'nix-build build.nix --keep-going -A nixpkgsUnstable.php54' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php54-imagick' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php54-memcached' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php54-redis' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php54-timezonedb' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php54-zendopcache' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php54-image' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php54-test --out-link result-php54'
                    }
                    catch (exception) {
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
        stage('PHP 55') {
            steps {
                script {
                    try {
                        sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                            'nix-build build.nix --keep-going -A nixpkgsUnstable.php55' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php55-dbase' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php55-imagick' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php55-intl' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php55-timezonedb' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php55-image' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php55-test --out-link result-php55'
                    }
                    catch (exception) {
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
        stage('PHP 56') {
            steps {
                script {
                    try {
                        sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                            'nix-build build.nix --keep-going -A nixpkgsUnstable.php56' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php56-dbase' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php56-imagick' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php56-intl' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php56-timezonedb' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php56-image' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php56-test --out-link result-php56'
                    }
                    catch (exception) {
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
        stage('PHP 70') {
            steps {
                script {
                    try {
                        sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                            'nix-build build.nix --keep-going -A nixpkgsUnstable.php70' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php70-imagick' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php70-memcached' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php70-redis' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php70-rrd' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php70-timezonedb' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php70-image' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php70-test --out-link result-php70'
                    }
                    catch (exception) {
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
        stage('PHP 71') {
            steps {
                script {
                    try {
                        sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                            'nix-build build.nix --keep-going -A nixpkgsUnstable.php71' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php71-imagick' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php71-memcached' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php71-redis' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php71-rrd' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php71-timezonedb' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php71-image' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php71-test --out-link result-php71'
                    }
                    catch (exception) {
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
        stage('PHP 72') {
            steps {
                script {
                    try {
                        sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                            'nix-build build.nix --keep-going -A nixpkgsUnstable.php72' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php72-imagick' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php72-memcached' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php72-redis' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php72-rrd' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php72-timezonedb' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php72-image' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php72-test --out-link result-php72'
                    }
                    catch (exception) {
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
        stage('PHP 73') {
            steps {
                script {
                    try {
                        sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                            'nix-build build.nix --keep-going -A nixpkgsUnstable.php73' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php73-imagick' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php73-memcached' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php73-redis' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php73-rrd' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php73-timezonedb' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php73-image' +
                            '&& nix-build build.nix --keep-going -A nixpkgsUnstable.php73-test --out-link result-php73'
                    }
                    catch (exception) {
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
    }
    post {
        success { notifySlack "Build ${JOB_NAME} succeeded" , "green" }
        failure { notifySlack "Build failled: ${JOB_NAME} [<${RUN_DISPLAY_URL}|${BUILD_NUMBER}>]", "red" }
        always {
            publishHTML (target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: false,
                    keepAll: true,
                    reportDir: 'result-php52/coverage-data/vm-state-docker',
                    reportFiles: 'bitrix_server_test.html, phpinfo.html',
                    reportName: "php52"
                ])
            publishHTML (target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: false,
                    keepAll: true,
                    reportDir: 'result-php53/coverage-data/vm-state-docker',
                    reportFiles: 'bitrix_server_test.html, phpinfo.html',
                    reportName: "php53"
                ])
            publishHTML (target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: false,
                    keepAll: true,
                    reportDir: 'result-php54/coverage-data/vm-state-docker',
                    reportFiles: 'bitrix_server_test.html, phpinfo.html',
                    reportName: "php54"
                ])
            publishHTML (target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: false,
                    keepAll: true,
                    reportDir: 'result-php55/coverage-data/vm-state-docker',
                    reportFiles: 'bitrix_server_test.html, phpinfo.html',
                    reportName: "php55"
                ])
            publishHTML (target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: false,
                    keepAll: true,
                    reportDir: 'result-php56/coverage-data/vm-state-docker',
                    reportFiles: 'bitrix_server_test.html, phpinfo.html',
                    reportName: "php56"
                ])
            publishHTML (target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: false,
                    keepAll: true,
                    reportDir: 'result-php70/coverage-data/vm-state-docker',
                    reportFiles: 'bitrix_server_test.html, phpinfo.html',
                    reportName: "php70"
                ])
            publishHTML (target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: false,
                    keepAll: true,
                    reportDir: 'result-php71/coverage-data/vm-state-docker',
                    reportFiles: 'bitrix_server_test.html, phpinfo.html',
                    reportName: "php71"
                ])
            publishHTML (target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: false,
                    keepAll: true,
                    reportDir: 'result-php72/coverage-data/vm-state-docker',
                    reportFiles: 'bitrix_server_test.html, phpinfo.html',
                    reportName: "php72"
                ])
            publishHTML (target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: false,
                    keepAll: true,
                    reportDir: 'result-php73/coverage-data/vm-state-docker',
                    reportFiles: 'bitrix_server_test.html, phpinfo.html',
                    reportName: "php73"
                ])
            cleanWs()
        }
    }
}
