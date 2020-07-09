case $(uname -s) in
  Linux*)
    readonly STEAMCMD=/usr/games/steamcmd
    #readonly INSTALLDIR=$STEAMDIR/mods
    readonly STEAMINSTALLDIR=$INSTALLDIR
  ;;
  CYGWIN*)
    readonly STEAMCMD="cmd.exe /c C:\\steamcmd\\steamcmd.exe"
    readonly STEAMINSTALLDIR="$(cygpath -w $(readlink -e $INSTALLDIR))"
    readonly WINDOWS=yes
  ;;
esac
