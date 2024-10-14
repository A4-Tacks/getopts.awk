A simple `getopts` for gawk

## Examples

```gawk
@include "./getopts.awk"

BEGIN {
    OPTIND = 1
    OPTRES = ""

    while (opt = getopts("hdf:")) switch (opt) {
        case "h":
            print "Usage: example.awk [-h] [-v] [-f <FILE>]"
            exit 0
        case "d":
            print "enable debug"
            break
        case "f":
            print "required file=" OPTARG
            break
        case "--":
            print "read options finish"

            for (; OPTIND < ARGC; ++OPTIND) {
                print "pos arg: " ARGV[OPTIND]
            }

            exit
        case "?":
            print "unknown option: " OPTARG
            exit 2
        case ":":
            print "option "OPTARG" expected a value, but cannot be found"
            exit 2
    }
}
```
