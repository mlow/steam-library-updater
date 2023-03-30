#!/bin/bash

set -eo pipefail

STEAMROOT=/steam/.steam

# Get the UID and GID of the ${STEAMROOT} ownership
UID=$(stat -c'%u' "${STEAMROOT}")
GID=$(stat -c'%g' "${STEAMROOT}")

# Force steamcmd to install steam into ${STEAMROOT} instead of $HOME/Steam
if [ ! -h "${STEAMROOT}/steam" ]; then
	ln -sf "${STEAMROOT}" "${STEAMROOT}/steam"
fi
# ... continued
mkdir -p "${STEAMROOT}/steamcmd/linux32"
cp -u /usr/lib/games/steam/steamcmd.sh "$STEAMROOT/steamcmd/"
cp -u /usr/lib/games/steam/steamcmd    "$STEAMROOT/steamcmd/linux32/"

# Set proper ownership and permissions for $STEAMROOT
chown -R $UID:$GID "${STEAMROOT}/steamcmd" "${STEAMROOT}/steam"

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
setpriv --reuid=$UID --regid=$GID --clear-groups "${STEAMROOT}"/steamcmd/steamcmd.sh $@
