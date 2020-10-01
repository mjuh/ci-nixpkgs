DOCUMENT_ROOT="${DOCUMENT_ROOT:-/workdir}"
export DOCUMENT_ROOT

string_join()
{
    IFS="$1"
    shift
    echo "$*"
}

workdir()
{
    IFS="/" read -r -a cwd_list <<< "$1"
    echo "/workdir/$(string_join "/" "${cwd_list[@]:3}")"
}

case "$1" in
    install)
        cd /workdir || exit 1
        $COMMAND_INSTALL
        eval "${@:2}" # Shell команды выполняемые во время сборки
        ;;
    shell | sh)
        cd "$(workdir "$DOCUMENT_ROOT")" || exit 1
        eval "${@:2}" # Shell команды выполняемые во время обновления
        ;;
esac
