if [ -z "$BIN" ]; then
  if [ -z "$PLATFORM" ]; then
    echo "Requires BIN or PLATFORM to be set"
    exit 1
  fi
  if [ -z "$INSTALLDIR" ]; then
    echo "Requires INSTALLDIR"
    exit 1
  fi
fi

if [ -z "$PLATFORM" ]; then
  source $BIN/internal/platform.sh
fi

case $PLATFORM in
  linux)
    readonly STEAMCMD=/usr/games/steamcmd
    readonly STEAMINSTALLDIR=$INSTALLDIR
  ;;
  wls)
    readonly STEAMCMD=/mnt/c/steamcmd/steamcmd.exe
    readonly STEAMINSTALLDIR="$(wslpath -w $INSTALLDIR)"
  ;;
  cygwin)
    readonly STEAMCMD="cmd.exe /c C:\\steamcmd\\steamcmd.exe"
    readonly STEAMINSTALLDIR="$(cygpath -w $(readlink -e $INSTALLDIR))"
  ;;
esac
