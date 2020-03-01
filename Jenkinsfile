properties([disableConcurrentBuilds(),
            gitLabConnection("gitlab.intr"),
            pipelineTriggers([cron(env.BRANCH_NAME == "master" ? "H 3 * * 1-5" : "")]),
            parameters([string(name: "PARALLEL", defaultValue: (env.BRANCH_NAME == "master" ? "5" : "3"),
                               description: "Number of triggered jobs in parallel simultaneously")])])

def parameterizedBuild (Map args = [:]) {
    assert args.job : "No build job"
    warnError("Failed to build the job") {
        build job: "${args.job}/master",
        parameters: [string(name: "OVERLAY_BRANCH_NAME", value: BRANCH_NAME),
                     booleanParam(name: "DEPLOY", value: (args.deploy ?: true)),
                     string(name: "NIX_PATH", value: (args.nixPath ?: ""))
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
            downstream.collate(params.PARALLEL.toInteger()).each { jobs ->
                parallel (jobs.collectEntries { job -> [(job): {parameterizedBuild (job: job, deploy: deploy, nixPath: nixPath)}]})}
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
