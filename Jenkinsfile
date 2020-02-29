properties([disableConcurrentBuilds()])

def parameterizedBuild (String job) {
    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
        build job: "$job/master",
        parameters: [string(name: 'OVERLAY_BRANCH_NAME', value: BRANCH_NAME),
                     // string(name: 'UPSTREAM_BRANCH_NAME', value: 'master'),
                     // booleanParam(name: 'DEPLOY', value: true)
        ]
    }
}

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
    "../ssh-sup-room"
]

String nixFetchSrcExpr = '''
with import <nixpkgs> { };
lib.filter (package: lib.isDerivation package) (map (package: package.src)
  (lib.filter (package: lib.hasAttrByPath [ "src" ] package)
    (import ./build.nix)))
'''.split("\n").collect{it.trim()}.join(" ")

String nixFetchSrcCmd = ["nix-build", "--no-build-output", "--no-out-link",
                         "--expr", "'$nixFetchSrcExpr'"].join(" ")

node() {
    stage("Fetch sources") {
        checkout scm
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            sh ([nixFetchSrcCmd, ("$nixFetchSrcCmd --check")].join("; "))
        }
    }
    stage("Build overlay") {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            sh "nix-build build.nix --keep-failed --show-trace --no-build-output"
        }
    }
    stage("Parallel"){ // Trigger jobs
        downstream.collate(3).collect { jobs ->
            switch (jobs.size()) {
                case 3:
                    parallel (
                        "${jobs[0]}": {parameterizedBuild jobs[0]},
                        "${jobs[1]}": {parameterizedBuild jobs[1]},
                        "${jobs[2]}": {parameterizedBuild jobs[2]}
                    )
                    break
                case 2:
                    parallel (
                        "${jobs[0]}": {parameterizedBuild jobs[0]},
                        "${jobs[1]}": {parameterizedBuild jobs[1]}
                    )
                    break
                case 1:
                    parameterizedBuild jobs[0]
                    break
            }
        }
    }
}
