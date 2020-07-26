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

installdir=$STEAMDIR/$installpath

case $PLATFORM in
  linux)
    STEAMCMD=/usr/games/steamcmd
    STEAMINSTALLDIR=$installdir
  ;;
  wls)
    STEAMCMD=/mnt/c/steamcmd/steamcmd.exe
    STEAMINSTALLDIR="$(wslpath -w $installdir)"
  ;;
  cygwin)
    STEAMCMD="cmd.exe /c C:\\steamcmd\\steamcmd.exe"
    STEAMINSTALLDIR="$(cygpath -w $(readlink -e $installdir))"
  ;;
esac
