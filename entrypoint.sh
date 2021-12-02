#!/bin/bash

set -eo pipefail

STEAMROOT=/steam/.steam

# change steam user uid/gid to runtime values
groupmod -g $GID steam
usermod -u $UID -g $GID steam

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

# Set Steam credentials and platform
sed -i \
	-e "s/%CREDENTIALS%/${STEAM_USERNAME} ${STEAM_PASSWORD}/" \
	-e "s/%PLATFORM%/${STEAM_PLATFORM}/" \
	commands.txt

if [ "$2" = "/steam/commands.txt" ]; then
	# only fetch library if we're going to use it
	echo "Fetching library..."
	/usr/local/bin/steamcmd-app-update | tee apps.txt
	echo
fi

echo "Running steamcmd..."
runuser -u steam "${STEAMROOT}"/steamcmd/steamcmd.sh $@
