case $(uname -s) in
  Linux*)
    if grep -q Microsoft /proc/version; then
      # WSL on Windows
      readonly PLATFORM=wls
      readonly WINDOWS=yes
    else
      # Native Linux
      readonly PLATFORM=linux
      readonly WINDOWS=no
    fi
  ;;
  CYGWIN*)
    # Cygwin on Windows
    readonly WINDOWS=yes
    readonly PLATFORM=cygwin
  ;;
esac
