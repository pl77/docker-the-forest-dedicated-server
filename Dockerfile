FROM ubuntu:18.04

LABEL maintainer="Sebastian Schmidt"

ENV WINEPREFIX=${WINEPREFIX} \
    DEBIAN_FRONTEND=${DEBIAN_FRONTEND} \
    PUID=${PUID} \
    PGID=${PGID} \
    SERVERNAME=${SERVERNAME} \
    SERVERPORT=${SERVERPORT} \
    QUERYPORT=${QUERYPORT} \
    STEAMPORT=${STEAMPORT} \
    SERVERPASSWORD=${SERVERPASSWORD} \
    SERVERADMINPASSWORD=${SERVERPORT}

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y wget software-properties-common supervisor apt-transport-https xvfb winbind cabextract \
    && wget https://dl.winehq.org/wine-builds/winehq.key \
    && apt-key add winehq.key \
    && rm winehq.key \
    && apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/ \
    && add-apt-repository ppa:cybermax-dexter/sdl2-backport \
    && apt-get update \
    && apt-get install -y winehq-stable \
    && wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x ./winetricks \
    && WINEDLLOVERRIDES="mscoree,mshtml=" wineboot -u \
    && wineserver -w \
    && ./winetricks -q winhttp wsh57 vcrun6sp6

COPY . ./

RUN apt-get remove -y software-properties-common apt-transport-https cabextract \
    && rm -rf winetricks /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && echo ${TIMEZONE} > /etc/timezone \
    && chmod +x /usr/bin/steamcmdinstaller.sh /usr/bin/servermanager.sh /wrapper.sh

RUN mkdir /theforest && mkdir /theforest/config

RUN echo "serverIP ${SERVERIP}\n" \
         "serverSteamPort ${STEAMPORT}\n" \
         "serverGamePort ${GAMEPORT}\n" \
         "serverQueryPort ${QUERYPORT}\n" \
         "serverName ${SERVERNAME}\n" \
         "serverPlayers ${MAXPLAYERS}\n" \
         "enableVAC ${ENABLEVAC}\n" \
         "serverPassword ${SERVERPASSWORD}\n" \
         "serverPasswordAdmin ${SERVERADMINPASSWORD}\n" \
         "serverSteamAccount ${STEAMACCOUNT}\n" \
         "serverAutoSaveInterval ${AUTOSAVEINTERVAL}\n" \
         "difficulty ${DIFFICULTY}\n" \
         "initType ${INITTYPE}\n" \
         "slot ${SLOT}\n" \
         "showLogs ${SHOWLOGS}\n" \
         "serverContact ${SERVERCONTACT}\n" \
         "veganMode ${VEGANMODE}\n" \
         "vegetarianMode ${VEGETARIANMODE}\n" \
         "resetHolesMode ${RESETHOLESMODE}\n" \
         "treeRegrowMode ${TREEREGROWMODE}\n" \
         "allowBuildingDestruction ${ALLOWBUILDINGDESTRUCTION}\n" \
         "allowEnemiesCreativeMode ${ALLOWENEMIESCREATIVEMODE}\n" \
         "allowCheats ${ALLOWCHEATS}\n" \
         "saveFolderPath ${SAVEFOLDERPATH}\n" \
         "targetFpsIdle ${TARGETFPSIDLE}\n" \
         "targetFpsActive ${TARGETFPSACTIVE}\n" \
         "configfilepath ${CONFIGFILEPATH}\n" \
         "realisticPlayerDamage ${REALISTICPLAYERDAMAGE}\n" > ${CONFIGFILEPATH}

EXPOSE ${STEAMPORT}/tcp ${STEAMPORT}/udp ${SERVERPORT}/tcp ${SERVERPORT}/udp ${QUERYPORT}/tcp ${QUERYPORT}/udp

VOLUME ["/theforest", "/steamcmd"]

CMD ["supervisord"]
