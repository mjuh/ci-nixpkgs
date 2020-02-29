properties([disableConcurrentBuilds(),
            gitLabConnection("gitlab.intr"),
            pipelineTriggers([cron(env.BRANCH_NAME == "master" ? "H 3 * * 1-5" : "")])])

def parameterizedBuild (Map args = [:]) {
    assert args.job : "No build job"
    String job = args.job
    Boolean deploy = args.deploy ?: true
    String nixPath = args.nixPath ?: ""
    warnError("Failed to build the job") {
        build job: "$job/master",
        parameters: [string(name: "OVERLAY_BRANCH_NAME", value: BRANCH_NAME),
                     booleanParam(name: "DEPLOY", value: deploy),
                     string(name: "NIX_PATH", value: nixPath)
        ]
    }
}

def buildOverlay(Map args = [:]) {
    Boolean deploy = args.deploy ?: true
    String nixPath = args.nixPath ?: ""

    List<String> downstream = [
        "../apache2-php44",
        "../apache2-php52",
        "../apache2-php53",
        "../../tests/php54",
        "../apache2-php54",
        "../../tests/php55",
        "../apache2-php55",
        "../../tests/php56",
        "../apache2-php56",
        "../../tests/php70",
        "../apache2-php70",
        "../../tests/php71",
        "../apache2-php71",
        "../../tests/php72",
        "../apache2-php72",
        "../../tests/php73",
        "../apache2-php73",
        "../../tests/php74",
        "../apache2-php74",
        "../apache2-php73-personal",
        "../cron",
        "../ftpserver",
        "../postfix",
        "../ssh-guest-room",
        "../ssh-sup-room",
        "../nginx"
    ]

    String nixFetchSrcExpr = '''
with import <nixpkgs> { };
lib.filter (package: lib.isDerivation package) (map (package: package.src)
  (lib.filter (package: lib.hasAttrByPath [ "src" ] package)
    (import ./build.nix)))
'''.split("\n").collect{it.trim()}.join(" ")

    String nixFetchSrcCmd = ["nix-build", "--no-build-output", "--no-out-link",
                             "--expr", "'$nixFetchSrcExpr'"].join(" ")

    node("nixbld") {
        stage("Fetch sources") {
            checkout scm
            warnError("Failed to fetch sources") {
                sh ([nixFetchSrcCmd, ("$nixFetchSrcCmd --check")].join("; "))
            }
        }
        stage("Build overlay") {
            warnError("Failed to build the overlay") {
                sh "nix-build build.nix --keep-failed --show-trace --no-build-output"
            }
        }
        stage("Trigger jobs") {
            downstream.collate(3).collect { jobs ->
                switch (jobs.size()) {
                    case 3:
                        parallel (
                            "${jobs[0]}": {
                                parameterizedBuild (job: jobs[0],
                                                    deploy: deploy,
                                                    nixPath: nixPath)},
                            "${jobs[1]}": {
                                parameterizedBuild (job: jobs[1],
                                                    deploy: deploy,
                                                    nixPath: nixPath)},
                            "${jobs[2]}": {
                                parameterizedBuild (job: jobs[2],
                                                    deploy: deploy,
                                                    nixPath: nixPath)}
                        )
                        break
                    case 2:
                        parallel (
                            "${jobs[0]}": {
                                parameterizedBuild (job: jobs[0],
                                                    deploy: deploy,
                                                    nixPath: nixPath)},
                            "${jobs[1]}": {
                                parameterizedBuild (job: jobs[1],
                                                    deploy: deploy,
                                                    nixPath: nixPath)}
                        )
                        break
                    case 1:
                        parameterizedBuild (job: jobs[0],
                                            deploy: deploy,
                                            nixPath: nixPath)
                        break
                }
            }
        }
    }
}

// Entry point
if (currentBuild.getBuildCauses('hudson.triggers.TimerTrigger$TimerTriggerCause')) {
    String NIX_PATH = "NIX_PATH=" +
        (["nixos-config=/etc/nixos/configuration.nix",
          "nixpkgs=https://nixos.org/channels/nixos-19.09/nixexprs.tar.xz"].join(":"))
    buildOverlay(deploy: false)
    withEnv([NIX_PATH]) {
        buildOverlay(deploy: false, nixPath: NIX_PATH)
    }
} else {
    buildOverlay()
}
