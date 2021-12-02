#!/bin/bash

set -eo pipefail

STEAMROOT=/steam/.steam

# Change steam user uid/gid to that of ${STEAMROOT} ownership
GID=$(stat -c'%g' "${STEAMROOT}")
UID=$(stat -c'%u' "${STEAMROOT}")
groupmod -g $GID steam > /dev/null
usermod -u $UID -g $GID steam > /dev/null

# Force steamcmd to install steam into ${STEAMROOT} instead of $HOME/Steam
if [ ! -h "${STEAMROOT}/steam" ]; then
	runuser -u steam ln -sf "${STEAMROOT}" "${STEAMROOT}/steam"
fi
# ... continued
if [ ! -d "${STEAMROOT}/steamcmd" ]
then
	runuser -u steam mkdir -p "${STEAMROOT}/steamcmd/linux32"
	runuser -u steam cp /usr/lib/games/steam/steamcmd.sh "$STEAMROOT/steamcmd/"
	runuser -u steam cp /usr/lib/games/steam/steamcmd    "$STEAMROOT/steamcmd/linux32/"
fi


if [ "$2" = "/steam/commands.txt" ]; then
	# only fetch library if we're going to use it
	echo "Fetching library..."
	/usr/local/bin/steamcmd-app-update | tee apps.txt
	echo

	cat <<- EOF > commands.txt
	@NoPromptForPassword 1
	@sSteamCmdForcePlatformType ${STEAM_PLATFORM}

	login ${STEAM_USERNAME} ${STEAM_PASSWORD}
	runscript /steam/apps.txt
	quit
	EOF
fi

echo "Running steamcmd..."
runuser -u steam "${STEAMROOT}"/steamcmd/steamcmd.sh $@
