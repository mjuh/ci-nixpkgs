@Library('mj-shared-library') _

def dependentJobs = [
	'ssh-guest-room',
	'ssh-sup-room',
        'cron',
	'apache2-php44',
	'apache2-php52',
	'apache2-php53',
	'apache2-php54',
	'apache2-php55',
	'apache2-php56',
	'apache2-php70',
	'apache2-php71',
	'apache2-php72',
	'apache2-php73',
	'apache2-php74',
	'apache2-php73-personal',
	'postfix',
	'ftpserver'
]

pipeline {
    agent { label 'nixbld' }
    stages {
        stage('Build overlay') {
            steps {
                nixSh cmd: 'nix-build build.nix --keep-failed --show-trace --no-build-output'
            }
        }
    stage('Trigger jobs') {
            steps {
				script {
					dependentJobs.each {
						build job: "../${it}/master", parameters: [[$class: 'StringParameterValue', name: 'OVERLAY_BRANCH_NAME', value: env.GIT_BRANCH]]
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
