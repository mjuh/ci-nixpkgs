def withNixShell(String command) {
    String.format("nix-shell pkgs/nix-shell --run '%s'", command)
}

pipeline {
    agent { label "master" }
    environment {
        GITLAB_PRIVATE_TOKEN = credentials("GITLAB_JENKINS_API_KEY")
        GITLAB_PROJECT_NAME = gitRemoteOrigin.getProject()
        GITLAB_GROUP_NAME = gitRemoteOrigin.getGroup()
    }
    stages {
        stage("Update packages") {
            steps {
                ansiColor("xterm") {
                    script {
                        // Build script
                        String buildCommand = withNixShell "nix build .#nix-overlay-update-script --print-build-logs"
                        sh buildCommand

                        // Run script
                        String scriptPath = withNixShell "nix path-info .#nix-overlay-update-script --print-build-logs"
                        String out = (sh (script: scriptPath, returnStdout: true)).trim()

                        sh out
                    }
                }
            }
        }
    }
    post {
        always {
            sendNotifications currentBuild.result
        }
    }
}
