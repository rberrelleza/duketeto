FROM golang:1.14-buster AS easy-novnc-build
WORKDIR /src
RUN go mod init build && \
    go get github.com/geek1011/easy-novnc@v1.1.0 && \
    go build -o /bin/easy-novnc github.com/geek1011/easy-novnc

FROM debian:bullseye

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends openbox tigervnc-standalone-server supervisor gosu && \
    rm -rf /var/lib/apt/lists && \
    mkdir -p /usr/share/desktop-directories

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends lxterminal nano wget openssh-client rsync ca-certificates xdg-utils htop tar xzip gzip bzip2 zip unzip gnupg curl && \
    rm -rf /var/lib/apt/lists

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    curl https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
    echo "deb https://dl.winehq.org/wine-builds/debian/ bullseye main" > /etc/apt/sources.list.d/wine.list && \
    apt-get update

RUN apt-get install -y --install-recommends winehq-stable && \
    curl -o /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
    chmod +x /usr/bin/winetricks && \
    rm -rf /var/lib/apt/lists
    
WORKDIR /eduke3d

RUN apt-get update && \
    apt-get install -y wget p7zip  && \
    wget https://dukeworld.com/eduke32/synthesis/latest/eduke32_win32_20210404-9321-7225643e3.7z && \
    7zr x eduke32_win32_*.7z && \
    wget https://github.com/zear/eduke32/raw/master/polymer/eduke32/duke3d.grp && \
    rm -f eduke32_win32_*.7z && \
    rm -rf /var/lib/apt/lists

COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY menu.xml /etc/xdg/openbox/
COPY supervisord.conf /etc/
EXPOSE 8080

COPY eduke32 /usr/bin/eduke32
VOLUME /root/.wine

ENV WINEDLLOVERRIDES="mscoree,mshtml="

CMD ["supervisord"]