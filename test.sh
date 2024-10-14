#!/usr/bin/bash
set -o nounset
set -o errtrace
#set -o pipefail
function CATCH_ERROR {
    local __LEC=$? __i
    echo "Traceback (most recent call last):" >&2
    for ((__i = ${#FUNCNAME[@]} - 1; __i >= 0; --__i)); do
        printf '  File %q line %s in %q\n' >&2 \
            "${BASH_SOURCE[$__i]}" \
            "${BASH_LINENO[$__i]}" \
            "${FUNCNAME[$__i]}"
    done
    echo "Error: [ExitCode: ${__LEC}]" >&2
    exit "${__LEC}"
}
trap CATCH_ERROR ERR

hash diff cat

trap '(exit 3)' int

function run_test {
    diff --color=auto - <(
        LEC=0
        gawk -f ./example.awk -- "${@:2}" || LEC=$?
        if [ "$LEC" -ne "${1}" ]; then
            echo "Unexpected exit status ${LEC}, expected $1" >&2
            kill -int $$
        fi
    )
}

run_test 0 -h << EOF
Usage: example.awk [-h] [-v] [-f <FILE>]
EOF

run_test 0 -hf << EOF
Usage: example.awk [-h] [-v] [-f <FILE>]
EOF

run_test 0 -fout << EOF
required file=out
read options finish
EOF

run_test 0 -f out << EOF
required file=out
read options finish
EOF

run_test 0 -dfout << EOF
enable debug
required file=out
read options finish
EOF

run_test 0 -ddfout << EOF
enable debug
enable debug
required file=out
read options finish
EOF


run_test 0 -d -fout << EOF
enable debug
required file=out
read options finish
EOF

run_test 0 -dd -fout << EOF
enable debug
enable debug
required file=out
read options finish
EOF

run_test 0 -d -dfout << EOF
enable debug
enable debug
required file=out
read options finish
EOF

run_test 0 -d -d -fout << EOF
enable debug
enable debug
required file=out
read options finish
EOF

run_test 0 -d -d -f '' << EOF
enable debug
enable debug
required file=
read options finish
EOF

run_test 2 -d -d -f << EOF
enable debug
enable debug
option f expected a value, but cannot be found
EOF

run_test 2 -e << EOF
unknown option: e
EOF

run_test 2 --long << EOF
unknown option: -
EOF

run_test 0 -- -e << EOF
read options finish
pos arg: -e
EOF

run_test 0 -- -h << EOF
read options finish
pos arg: -h
EOF

run_test 0 -- -- -h << EOF
read options finish
pos arg: --
pos arg: -h
EOF

run_test 0 m -h << EOF
read options finish
pos arg: m
pos arg: -h
EOF
