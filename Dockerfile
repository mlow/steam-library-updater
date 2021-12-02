FROM node:17-bullseye

# Install steamcmd
ARG DEBIAN_FRONTEND=noninteractive
RUN sed -i -e 's/debian bullseye main/debian bullseye main non-free/' /etc/apt/sources.list \
    && { echo steam steam/question select "I AGREE" | debconf-set-selections ; } \
    && { echo steam steam/license note "" | debconf-set-selections ; } \
    && dpkg --add-architecture i386 \
    && apt-get update -y \
    && apt-get install --no-install-recommends -y locales steamcmd \
    && sed -i -e 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen \
    && locale-gen

# Rename the node user and group to 'steam'
RUN usermod -l steam -d /steam node && groupmod -n steam node

# Install steamcmd-app-update
RUN npm install -g  git+https://github.com/mlow/steamcmd-app-update.git

WORKDIR /steam
COPY entrypoint.sh commands.txt ./

## Change the following at runtime
# ... variables for steamcmd-app-update
ENV STEAM_API_KEY= STEAM_PROFILE_ID= SKIP_GAMES= FORCE_VALIDATE=
# ... variables for steamcmd. Note: default platform is windows
# Possible platforms: linux, windows, macos
ENV STEAM_USERNAME= STEAM_PASSWORD= STEAM_PLATFORM=windows

# Don't change
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en

VOLUME ["/steam/.steam"]
ENTRYPOINT ["./entrypoint.sh"]
CMD ["+runscript", "/steam/commands.txt"]
