FROM ubuntu:18.04

LABEL maintainer="Sebastian Schmidt"

ENV WINEPREFIX=/wine DEBIAN_FRONTEND=noninteractive PUID=0 PGID=0 \
    SERVERNAME=Der-Wald \
    SERVERPORT=27015 \
    QUERYPORT=27016 \
    STEAMPORT=8766 \
    SERVERPASSWORD=changeme \
    SERVERADMINPASSWORD=changeme


RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y wget software-properties-common supervisor apt-transport-https xvfb winbind cabextract \
    && wget https://dl.winehq.org/wine-builds/winehq.key \
    && apt-key add winehq.key \
    && rm winehq.key \
    && apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/ \
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
    && echo $TIMEZONE > /etc/timezone \
    && chmod +x /usr/bin/steamcmdinstaller.sh /usr/bin/servermanager.sh /wrapper.sh

RUN mkdir /theforest && mkdir /theforest/config

RUN echo "serverIP 0.0.0.0\n" \
         "serverSteamPort ${STEAMPORT}\n" \
         "serverGamePort ${SERVERPORT}\n" \
         "serverQueryPort ${QUERYPORT}\n" \
         "serverName ${SERVERNAME}\n" \
         "serverPlayers 8\n" \
         "enableVAC off\n" \
         "serverPassword ${SERVERPASSWORD}\n" \
         "serverPasswordAdmin ${SERVERADMINPASSWORD}\n" \
         "serverSteamAccount\n" \
         "serverAutoSaveInterval 30\n" \
         "difficulty Normal\n" \
         "initType Continue\n" \
         "slot 1\n" \
         "showLogs off\n" \
         "serverContact email@gmail.com\n" \
         "veganMode off\n" \
         "vegetarianMode off\n" \
         "resetHolesMode off\n" \
         "treeRegrowMode off\n" \
         "allowBuildingDestruction on\n" \
         "allowEnemiesCreativeMode off\n" \
         "allowCheats off\n" \
         "realisticPlayerDamage off\n" \
         "saveFolderPath\n" \
         "targetFpsIdle 0\n" \
         "targetFpsActive 0\n" > /theforest/config/config.cfg

EXPOSE ${STEAMPORT}/tcp ${STEAMPORT}/udp ${SERVERPORT}/tcp ${SERVERPORT}/udp ${QUERYPORT}/tcp ${QUERYPORT}/udp

VOLUME ["/theforest", "/steamcmd"]

CMD ["supervisord"]
