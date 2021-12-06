def lib = library('mj-shared-library')

def parameterizedBuild (Map args = [:]) {
    assert args.job : "No build job"
    warnError("Failed to build the job") {
        build job: "${args.job}/master",
        parameters: [string(name: "OVERLAY_BRANCH_NAME", value: BRANCH_NAME),
                     booleanParam(name: "DEPLOY", value: args.deploy),
                     booleanParam(name: "STACK_DEPLOY", value: args.stackDeploy),
                     string(name: "NIX_PATH", value: (args.nixPath ?: ""))
        ]
    }
}

String nixPath = ""

List<String> downstreamTests = [ // Fast passing jobs (around 20 seconds)
    "../../tests/php54",
    "../../tests/php55",
    "../../tests/php56",
    "../../tests/php70",
    "../../tests/php71",
    "../../tests/php72",
    "../../tests/php73",
    "../../tests/php74"
]
List<String> downstream = [
    "../apache2-perl518",

    // TODO: Run flake update --update-input majordomo then build.
    //
    // "../apache2-php52",
    // "../apache2-php53",
    // "../apache2-php54",
    // "../apache2-php55",
    // "../apache2-php56",
    // "../apache2-php70",
    // "../apache2-php71",
    // "../apache2-php72",
    // "../apache2-php73",
    // "../apache2-php74",
    // "../http-fileserver",
    // "../nginx",
    // "../ssh-sup-room",

    "../apache2-php74-personal",
    "../uwsgi-python37",
    "../cron",
    "../ftpserver",
    "../postfix",
    "../ssh-guest-room",
    "../webftp-new"
]

// XXX: Jobs which cannot be build reproducible.
List<String> nonReproducible = [
    "../webftp-new" // Frontend is build by third-party container
]

List<String> stackDeployApproved = [
    // Jobs which will be deployed to Docker Stack on push to
    // current Git repositoroty
]

def withNixShell(String command) {
    String.format("nix-shell --run '%s'", command)
}

String nixFeatures = String.format(
    '--experimental-features "%s"', ["nix-command", "flakes"].join(" "))

def slackMessages = []

pipeline {
    agent { label 'nixbld' }
    environment {
        GROUP_NAME = "ci"
        PROJECT_NAME = "nixpkgs"
    }
    triggers {
        cron(env.BRANCH_NAME == "master" ? "H 9 * * 1-5" : "")
    }
    options {
        disableConcurrentBuilds()
    }
    parameters{
        string(name: "PARALLEL", defaultValue: (env.BRANCH_NAME == "master" ? "5" : "3"),
               description: "Number of triggered jobs in parallel simultaneously")
        booleanParam(name: 'DEPLOY',
                     defaultValue: true,
                     description: 'Deploy Docker image to registry')
    }
    stages {
        stage("build") {
            steps {
                script {
                    List<String> command =
                        ["nix", "build", nixFeatures, ".#sources", "--impure"]
                    String nixFetchSrcCmd =
                        withNixShell([
                        command.join(" "),
                        (command + "--rebuild").join(" ")
                    ].join(";"))
                    parallel (
                        ["Fetch sources": {
                            warnError("Failed to fetch sources") {
                                sh ([nixFetchSrcCmd,
                                     (BRANCH_NAME == "master" ? "timeout 300 $nixFetchSrcCmd" : "true")].join("; "))
                            }
                        },
                         "Build overlay": {
                                warnError("Failed to build the overlay") {
                                    withNixShell "nix build --impure"
                                }
                            }
                        ]
                    )
                }
            }
        }
        stage("tests") {
            steps {
                script {
                    parallel(nix.check(scanPasswords: true))
                }
            }
        }
        stage("Trigger jobs") {
            steps {
                script {
                    downstreamJobs = downstream.collate(params.PARALLEL.toInteger()).collect { jobs ->
                        jobs.collectEntries { job ->
                            [(job): {parameterizedBuild (
                                        job: job,
                                        deploy: (job in nonReproducible ? false : params.deploy),
                                        stackDeploy: (job in stackDeployApproved && params.deploy),
                                        nixPath: nixPath
                                    )
                                }
                            ]
                        }
                    }
                    downstreamTestsJobs = downstreamTests.collectEntries { job ->
                        //XXX: parameterizedBuild is an overkill
                        [(job): {parameterizedBuild (
                                    job: job,
                                    deploy: false,
                                    stackDeploy: false,
                                    nixPath: nixPath
                                )
                            }
                        ]
                    }
                    ([downstreamTestsJobs + downstreamJobs.first()] + downstreamJobs.tail())
                        .each { jobs -> parallel jobs }
                }
            }
        }
    }
    post {
        always {
            sendSlackNotifications (
                buildStatus: currentBuild.result,
                threadMessages: slackMessages
            )
        }
    }
}
