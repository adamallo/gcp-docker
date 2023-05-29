# GCP Client

#base image from https://github.com/phusion/baseimage-docker
FROM phusion/baseimage:jammy-1.0.1

# Maintainer
MAINTAINER Diego Mallo "adamallo@gmail.com"

# update system
RUN apt-get update &&  apt-get upgrade -y && apt-get dist-upgrade -y

# install some system tools
RUN apt-get install -y wget

# install GCP client
RUN cd /opt && \
  wget -c https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz && \
  tar xzf globusconnectpersonal-latest.tgz
RUN rm /opt/globusconnectpersonal-latest.tgz
RUN mv /opt/globusconnectpersonal-* /opt/globusconnectpersonal

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure environment
ENV USER=globus \
    UID=1000 \
    GID=100 \
    HOME=/home/$USER

# Add scripts
ADD fix-permissions /usr/local/bin/fix-permissions
ADD setupUserAndStartGlobusConnect.sh /opt/globusconnectpersonal/setupUserAndStartGlobusConnect.sh

# Create globus user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN useradd -m -s /bin/bash -N -u $UID $USER && \
    fix-permissions $HOME
USER $USER

# Add GCP to PATH
ENV PATH /opt/globusconnectpersonal/:$PATH
CMD /opt/globusconnectpersonal/setupUserAndStartGlobusConnect.sh $USER $UID $GID $HOME $SETUP_KEY

