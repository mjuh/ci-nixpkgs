#!/usr/bin/env bash

# 1. Set GIT_BRANCH and GIT_COMMIT if they not provided.
# 2. Parse command line options.
# 3. Load a container packaged in /nix/store/...tar.gz to local Docker daemon.
# 4. Push the container to repository.

set -e
set -o pipefail

help_main()
{
    echo "\
Usage: deploy container --repository REPOSITORY FILE
"
}

PATH=@utilLinux@/bin:@git@/bin:@skopeo@/bin:@docker@/bin/:"$PATH"

if [[ $1 != container ]]
then
    exit 1
fi

# Setted in Jenkins Pipelines.
GIT_BRANCH="${GIT_BRANCH:-$(git branch --show-current)}"
GIT_COMMIT="${GIT_COMMIT:-$(git rev-parse HEAD)}"

if ! OPTS="$(getopt --options c:r:h --long container:,repository:,help --name parse-options -- "${@:2}")"
then
    echo "Failed parsing options."
    exit 1
fi

eval set -- "$OPTS"

while true; do
    case "$1" in
        -h | --help)
            help_main
            exit 0
            ;;
        -r | --repository)
            repository="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        ,*)
            break
            ;;
    esac
done

if [[ -z $repository ]]
then
    echo "'--repository' is not provided, exiting."
    exit 1
fi

container="${BASH_ARGV[0]}"

docker_images=(
    "$repository:${GIT_BRANCH}"
    "$repository:${GIT_COMMIT:0:8}"
)

for image in "${docker_images[@]}"
do
    skopeo copy docker-archive:"$container" docker-daemon:"$image"
    docker push "$image"
done
