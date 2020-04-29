case $(uname -s) in
  Linux*)
    readonly STEAMCMD=/usr/games/steamcmd
    #readonly INSTALLDIR=$STEAMDIR/mods
    readonly STEAMINSTALLDIR=$INSTALLDIR
  ;;
  CYGWIN*)
    readonly STEAMCMD=/cygdrive/c/steamcmd/steamcmd.exe
    readonly STEAMINSTALLDIR="$(cygpath -w $INSTALLDIR)"
    readonly WINDOWS=yes
  ;;
esac
