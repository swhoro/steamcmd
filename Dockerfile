######## INSTALL ########

# Set the base image
FROM debian:12-slim

# Insert Steam prompt answers
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo steam steam/question select "I AGREE" | debconf-set-selections \
 && echo steam steam/license note '' | debconf-set-selections

# Update the repository and install SteamCMD
ARG DEBIAN_FRONTEND=noninteractive
COPY sources.list /etc/apt/sources.list
RUN groupadd gaming && useradd -m -g gaming -s /bin/bash gaming && rm /etc/apt/sources.list.d/debian.sources \
 && apt-get update && apt-get install -y apt-transport-https ca-certificates \
 && sed -i "s/http/https/" /etc/apt/sources.list \
 && dpkg --add-architecture i386 \
 && apt-get update -y \
 && apt-get install -y --no-install-recommends ca-certificates locales steamcmd \
 && rm -rf /var/lib/apt/lists/*

# Add unicode support
RUN sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
 && locale-gen en_US.UTF-8
ENV LANG 'en_US.UTF-8'
ENV LANGUAGE 'en_US:en'

# Create symlink for executable
RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

USER gaming
# Set environment variables
# ENV USER gaming
# ENV HOME /home/gaming
# Set working directory
WORKDIR /home/gaming
# Update SteamCMD and verify latest version
RUN steamcmd +quit \
 # Fix missing directories and libraries
 && mkdir -p $HOME/.steam \
 && ln -s $HOME/.local/share/Steam/steamcmd/linux32 $HOME/.steam/sdk32 \
 && ln -s $HOME/.local/share/Steam/steamcmd/linux64 $HOME/.steam/sdk64 \
 && ln -s $HOME/.steam/sdk32/steamclient.so $HOME/.steam/sdk32/steamservice.so \
 && ln -s $HOME/.steam/sdk64/steamclient.so $HOME/.steam/sdk64/steamservice.so

# Set default command
ENTRYPOINT ["steamcmd"]
CMD ["+help", "+quit"]
