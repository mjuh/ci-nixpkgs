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
    "../apache2-php52",
    "../apache2-php53",
    "../apache2-php54",
    "../apache2-php55",
    "../apache2-php56",
    "../apache2-php70",
    "../apache2-php71",
    "../apache2-php72",
    "../apache2-php73",
    "../apache2-php74",
    "../apache2-php74-personal",
    "../uwsgi-python37",
    "../cron",
    "../ftpserver",
    "../postfix",
    "../ssh-guest-room",
    "../ssh-sup-room",
    "../nginx",
    "../http-fileserver",
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

String nixFetchSrcExpr = '''
with import <nixpkgs> { };
lib.filter (package: lib.isDerivation package) (map (package: package.src)
  (lib.filter (package: lib.hasAttrByPath [ "src" ] package)
    (import ./pkgs/scripts/build.nix { })))
'''.split("\n").collect{it.trim()}.join(" ")

String nixFetchSrcCmd = ["nix-build", "--no-build-output", "--no-out-link",
                         "--expr", "--timeout 60", "--keep-going", "'$nixFetchSrcExpr'"].join(" ")

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
        stage("Build") {
            steps {
                script {
                    parallel (
                        ["Fetch sources": {
                                String nixpkgsVersion =
                                    sh (script: "nix-instantiate --eval --expr '(import <nixpkgs> {}).lib.version'",
                                        returnStdout: true).trim().replace('"', "").split("\\.").last()

                                String shortCommit =
                                    sh(script: "git log -n 1 --format=%H",
                                       returnStdout: true).trim()

                                String nixReproduceExpr = String.format("""
(import (builtins.fetchTarball {
  url = "https://github.com/nixos/nixpkgs/archive/${nixpkgsVersion}.tar.gz";
}) {
  overlays = [
    (import (builtins.fetchGit {
      url = "git@gitlab.intr:_ci/nixpkgs.git";
      ref = "${shortCommit}";
    }))
  ];
}).php56
""", ).split("\n").collect{it.trim()}.join(" ")

                                String nixDomain = "cache.nixos.intr"
                                String nixSubstitute = "http://$nixDomain/"
                                String nixPubKey = "$nixDomain:6VD7bofl5zZFTEwsIDsUypprsgl7r9I+7OGY4WsubFA="

                                echo """Hint: You could fetch artifacts by invoking (e.g. for php56):
nix-build --substituters $nixSubstitute --option trusted-public-keys '$nixPubKey' --no-out-link --expr '$nixReproduceExpr'"""

                                warnError("Failed to fetch sources") {
                                    sh ([nixFetchSrcCmd,
                                         (BRANCH_NAME == "master" ? "timeout 300 $nixFetchSrcCmd --check" : "true")].join("; "))
                                }
                            },

                         "Build overlay": {
                                warnError("Failed to build the overlay") {
                                    sh "nix-build pkgs/scripts/build.nix --keep-failed --show-trace --no-build-output"
                                }
                            },

                         "Scan passwords in Git history": {
                                build (
                                    job: "../../ci/bfg/master",
                                    parameters: [
                                        string(
                                            name: "GIT_REPOSITORY_TARGET_URL",
                                            value: gitRemoteOrigin.getRemote().url
                                        )
                                    ]
                                )
                            }
                        ]
                    )
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
        stage("Publish on the Internet") {
            when {
                allOf {
                    not { triggeredBy("TimerTrigger") }
                    branch "master"
                }
            }
            steps {
                script {
                    comGithub.push group: GROUP_NAME, name: PROJECT_NAME
                    slackMessages += "${GROUP_NAME}/${PROJECT_NAME} pushed to github.com"
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
