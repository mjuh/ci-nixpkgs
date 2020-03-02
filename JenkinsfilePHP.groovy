pipeline {
    agent { label "nixbld" }
    environment {
        JUNIT_OUTPUT_DIRECTORY = "result/${env.JOB_NAME}"
        JUNIT_OUTPUT_PATH = "$JUNIT_OUTPUT_DIRECTORY/junit-${env.BUILD_NUMBER}"
        JUNIT_OUTPUT_XML = "$JUNIT_OUTPUT_DIRECTORY/junit-${env.BUILD_NUMBER}.xml"
    }
    stages {
        stage("Build junit") {
            steps {
                script {
                    String PROJECT_NAME = (env.JOB_NAME.tokenize('/') as String[])[1]
                    String output = (sh (script: "nix-build --out-link $JUNIT_OUTPUT_PATH --expr '(import <nixpkgs> {overlays = [(import \"${WORKSPACE}\")];}).${PROJECT_NAME}.junit'", returnStdout: true)).trim()
                    String junit_nix_store_xml = (sh (script: "readlink -f $output", returnStdout: true)).trim()
                    sh "cp $junit_nix_store_xml $JUNIT_OUTPUT_XML"
                    junit JUNIT_OUTPUT_XML
                }
            }
        }
    }
    post {
        always { sh "rm -f $JUNIT_OUTPUT_XML" }
        failure { notifySlack "Build failled: ${JOB_NAME} [<${RUN_DISPLAY_URL}|${BUILD_NUMBER}>]", "red" }
    }
}
