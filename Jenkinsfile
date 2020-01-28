@Library("mj-shared-library") _


def curriedBuild (String job) {
    build job: "../${job}/master",
    wait: false,
    parameters: [[$class: "StringParameterValue",
                  name: "OVERLAY_BRANCH_NAME", value: env.GIT_BRANCH]]
}

pipeline {
    agent { label "nixbld" }
    stages {
        stage("Build overlay") {
            steps {
                nixSh cmd: "nix-build build.nix --keep-failed --show-trace --no-build-output"
            }
        }
        stage ("Trigger jobs") {
            parallel {
                stage ("Trigger jobs") {
                    steps {
                        curriedBuild "apache2-php44"
                        curriedBuild "apache2-php52"
                        curriedBuild "apache2-php53"
                        curriedBuild "apache2-php54"
                        curriedBuild "apache2-php55"
                        curriedBuild "apache2-php56"
                        curriedBuild "apache2-php70"
                        curriedBuild "apache2-php71"
                        curriedBuild "apache2-php72"
                        curriedBuild "apache2-php73"
                        curriedBuild "apache2-php73-personal"
                        curriedBuild "apache2-php74"
                        curriedBuild "cron"
                        curriedBuild "ftpserver"
                        curriedBuild "postfix"
                        curriedBuild "ssh-guest-room"
                        curriedBuild "ssh-sup-room"
                    }
                }
            }
        }
    }
    post {
        success { notifySlack "Build ${JOB_NAME} succeeded" , "green" }
        failure { notifySlack "Build failled: ${JOB_NAME} [<${RUN_DISPLAY_URL}|${BUILD_NUMBER}>]", "red" }
    }
}
