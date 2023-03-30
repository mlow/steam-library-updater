#!/bin/bash

set -eo pipefail

STEAMROOT=/steam/.steam

# Get the UID and GID of ${STEAMROOT} ownership
STEAM_UID=$(stat -c'%u' "${STEAMROOT}")
STEAM_GID=$(stat -c'%g' "${STEAMROOT}")

# Force steamcmd to install steam into ${STEAMROOT} instead of $HOME/Steam
if [ ! -h "${STEAMROOT}/steam" ]; then
	ln -sf "${STEAMROOT}" "${STEAMROOT}/steam"
fi
# ... continued
if [ ! -d "${STEAMROOT}/steamcmd" ]; then
	mkdir -p "${STEAMROOT}/steamcmd/linux32"
	cp /usr/lib/games/steam/steamcmd.sh "$STEAMROOT/steamcmd/steamcmd.sh"
	cp /usr/lib/games/steam/steamcmd    "$STEAMROOT/steamcmd/linux32/steamcmd"
	chown -R $STEAM_UID:$STEAM_GID "${STEAMROOT}/steamcmd"
fi

if [ "$2" = "/steam/commands.txt" ]; then
	# only fetch library if we're going to use it
	echo "Fetching library..."
	/usr/local/bin/steamcmd-app-update | tee /steam/apps.txt
	echo

	cat <<- EOF > /steam/commands.txt
	@NoPromptForPassword 1
	@sSteamCmdForcePlatformType ${STEAM_PLATFORM}
	login ${STEAM_USERNAME} ${STEAM_PASSWORD}
	runscript /steam/apps.txt
	quit
	EOF
	chown $STEAM_UID:$STEAM_GID /steam/{commands,apps}.txt
fi

echo "Running steamcmd..."
export HOME=/steam
setpriv --reuid=$STEAM_UID --regid=$STEAM_GID --clear-groups "${STEAMROOT}"/steamcmd/steamcmd.sh $@
