case $(uname -s) in
  Linux*)
    #if grep -q Microsoft /proc/version; then
    #  readonly STEAMCMD=/mnt/c/steamcmd/steamcmd.exe
    #  readonly STEAMINSTALLDIR="$(wslpath -w $INSTALLDIR)"
    #else
      readonly STEAMCMD=/usr/games/steamcmd
      readonly STEAMINSTALLDIR=$INSTALLDIR
    #fi
    #readonly INSTALLDIR=$STEAMDIR/mods
  ;;
  CYGWIN*)
    readonly STEAMCMD="cmd.exe /c C:\\steamcmd\\steamcmd.exe"
    readonly STEAMINSTALLDIR="$(cygpath -w $(readlink -e $INSTALLDIR))"
    readonly WINDOWS=yes
  ;;
esac
