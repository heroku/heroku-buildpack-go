case $(ulimit -u) in

# Standard-2X DYNO
512)
  export GOMAXPROCS=${GOMAXPROCS:-2}
  ;;

# Intermediate DYNO
16384)
  export GOMAXPROCS=${GOMAXPROCS:-2}
  ;;

# Performance DYNO
32768)
  export GOMAXPROCS=${GOMAXPROCS:-4}
  ;;

# Default for other types, including Standard-1X
*)
  export GOMAXPROCS=${GOMAXPROCS:-1}
  ;;

esac
