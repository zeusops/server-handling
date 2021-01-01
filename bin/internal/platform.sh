case $(uname -s) in
  Linux*)
    if grep -q Microsoft /proc/version; then
      # WSL on Windows
      platform=wsl
      windows=yes
    else
      # Native Linux
      platform=linux
      windows=no
    fi
  ;;
  CYGWIN*)
    # Cygwin on Windows
    windows=yes
    platform=cygwin
  ;;
esac

export PLATFORM=${PLATFORM:-$platform}
export WINDOWS=${WINDOWS:-$windows}
