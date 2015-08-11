case $(ulimit -u) in

# Standard-2X DYNO
512)
  export GOMAXPROCS=${GOMAXPROCS:-2}
  ;;

# Performance-M
16384)
  export GOMAXPROCS=${GOMAXPROCS:-2}
  ;;

# Performance-L
32768)
  export GOMAXPROCS=${GOMAXPROCS:-8}
  ;;

# Default for other types, including Standard-1X
*)
  export GOMAXPROCS=${GOMAXPROCS:-1}
  ;;

esac
