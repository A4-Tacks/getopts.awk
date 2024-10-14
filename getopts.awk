#!/usr/bin/awk -f

###############################################################################
# States
#
# OPTIND is parse start index
# OPTARG is option value
# OPTRES rest options
###############################################################################
# Return values
#
# "--" is argc[OPTIND] until argc[argv-1] is position args
# "?" is a unknown option, OPTARG stores this option
# ":" expected a value, but cannot be found, OPTARG stores this option
# other string is a option, the option value comes from OPTARG
function getopts(optstring, argc, argv,     k, opt, opts) {
    if (typeof(argc) == "untyped") argc = ARGC;
    if (typeof(argv) == "untyped") for (k in ARGV) argv[k] = ARGV[k];
    if (typeof(OPTIND) == "untyped") OPTIND = 1;

    while (OPTIND < argc || OPTRES) {
        if (!OPTRES) {
            if (argv[OPTIND] == "--") { OPTIND++; break }
            if (argv[OPTIND] !~ /^-./) { break }

            OPTRES = substr(argv[OPTIND++], 2)
        }

        opt = substr(OPTRES, 1, 1)
        OPTRES = substr(OPTRES, 2)

        for (i = 1; i <= length(optstring); ++i) {
            opts = substr(optstring, i, 2)

            if (opt != substr(opts, 1, 1)) { continue }

            if (opts ~ /.:/) {
                if (OPTRES) { OPTARG = OPTRES; OPTRES = ""; return opt }
                if (OPTIND == argc) { OPTARG = opt; return ":" }

                OPTARG = argv[OPTIND++]
            }

            return opt
        }

        OPTARG = opt
        return "?"
    }

    return "--"
}
