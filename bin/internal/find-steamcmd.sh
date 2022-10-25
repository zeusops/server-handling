if [ -z "${bin:-$BIN}" ]; then
  if [ -z "${PLATFORM-}" ]; then
    echo "Requires BIN or PLATFORM to be set"
    exit 1
  fi
  if [ -z "${INSTALLDIR-}" ]; then
    echo "Requires INSTALLDIR"
    exit 1
  fi
fi

if [ -z "${PLATFORM-}" ]; then
  . $BIN/internal/platform.sh
fi

if [ "${INSTALL_ARMA:-no}" == "yes" ]; then
  install_dir=$armadir
else
  install_dir=$steam_dir/${INSTALL_PATH:-mods}
fi

if [ ! -d "$install_dir" ]; then
  >&2 echo "Steam install directory $install_dir not found (detected platform: $PLATFORM), exiting."
  exit 1
fi

case $PLATFORM in
  linux)
    for x in $steam_dir/steamcmd{,.sh} $HOME/steamcmd/steamcmd{,.sh} /usr/games/steamcmd; do
      if [ -x "$x" ]; then
        steamcmd="$x"
	break
      fi
    done
    steam_install_dir=$install_dir
  ;;
  wsl)
    steamcmd=/mnt/c/steamcmd/steamcmd.exe
    steam_install_dir="$(wslpath -w $install_dir)"
  ;;
  cygwin)
    steamcmd="cmd.exe /c C:\\steamcmd\\steamcmd.exe"
    steam_install_dir="$(cygpath -w $(readlink -e $install_dir))"
  ;;
esac

STEAMCMD=${STEAMCMD:-$steamcmd}
STEAM_INSTALL_DIR=${STEAM_INSTALL_DIR:-$steam_install_dir}
