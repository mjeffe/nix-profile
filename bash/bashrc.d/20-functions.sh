# small shell functions

# list the most recently changed files
lt() {
    ls -lArtF "$@" | tail -20
}

# biggest directories under the given paths (default: .)
dusort() {
    du "${@:-.}" | sort -rn | head -20
}
