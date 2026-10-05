ogenc_optimize(-fhardcfr-check-exceptions "Check CFR execution paths also when exiting a function through an exception." OFF)
ogenc_optimize(-fhardcfr-check-returning-calls "Check CFR execution paths also before calls followed by returns of their results." OFF)
ogenc_optimize(-fhardcfr-skip-leaf "Disable CFR in leaf functions." OFF)
ogenc_optimize(-fharden-control-flow-redundancy "Harden control flow by recording and checking execution paths." OFF)
ogenc_optimize(-finline-stringops "This option lacks documentation." OFF)
ogenc_optimize(-funreachable-traps "Trap on __builtin_unreachable instead of using it for optimization." OFF)
ogenc_optimize(-funwind-tables "Just generate unwind tables for exception handling." OFF)


