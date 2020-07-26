case $(uname -s) in
  Linux*)
    if grep -q Microsoft /proc/version; then
      # WSL on Windows
      PLATFORM=wls
      WINDOWS=yes
    else
      # Native Linux
      PLATFORM=linux
      WINDOWS=no
    fi
  ;;
  CYGWIN*)
    # Cygwin on Windows
    WINDOWS=yes
    PLATFORM=cygwin
  ;;
esac
