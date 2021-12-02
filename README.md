# steam-library-updater

Keep your entire Steam library up-to-date.

## Usage

### First run
```sh
STEAMDIR=/steam/path/on/host

docker run -it --rm \
  --env-file steam.env \
  -v "${STEAMDIR}:/steam/.steam" \
  steam-library-updater \
  +login <steam username>
```

You will be prompted for your password and your Steam Guard code. After
successfully logging in, type `quit` to leave the container.

#### Notes
* See `Dockerfile` for applicable `steam.env` variables.
* Ownership of the mounted volume is preserved. That is, `steamcmd` will be run
  as the current owner `${STEAMDIR}`.
* Games are downloaded to `${STEAMDIR}/steamapps/common`

### Subsuquent/scheduled runs
```sh
docker run --rm \
  --env-file steam.env \
  -v "${STEAMDIR}:/steam/.steam"
  steam-library-updater
```

Future runs will automatically log you in and proceed to download/update every
title in your library that's not in the `SKIP_GAMES` list.

Example `docker-compose.yml`:
```yml
services:
  steam-library-updater:
    build: https://github.com/mlow/steam-library-updater.git
    restart: "no"
    environment:
      STEAM_API_KEY:
      STEAM_PROFILE_ID:
      SKIP_GAMES:
      STEAM_USERNAME:
      STEAM_PASSWORD:
    volumes:
      - "/data/Steam:/steam/.steam"
```
