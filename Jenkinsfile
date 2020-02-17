@Library("mj-shared-library") _


def parameterizedBuild (String job) {
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
                sh "nix-build build.nix --keep-failed --show-trace --no-build-output"
            }
        }
        stage ("Trigger jobs") {
            parallel {
                stage ("Trigger jobs") {
                    steps {
                        parameterizedBuild "apache2-php44"
                        parameterizedBuild "apache2-php52"
                        parameterizedBuild "apache2-php53"
                        parameterizedBuild "apache2-php54"
                        parameterizedBuild "apache2-php55"
                        parameterizedBuild "apache2-php56"
                        parameterizedBuild "apache2-php70"
                        parameterizedBuild "apache2-php71"
                        parameterizedBuild "apache2-php72"
                        parameterizedBuild "apache2-php73"
                        parameterizedBuild "apache2-php73-personal"
                        parameterizedBuild "apache2-php74"
                        parameterizedBuild "cron"
                        parameterizedBuild "ftpserver"
                        parameterizedBuild "postfix"
                        parameterizedBuild "ssh-guest-room"
                        parameterizedBuild "ssh-sup-room"
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
