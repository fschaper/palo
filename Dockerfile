FROM ubuntu:latest

LABEL version="5.1.4"
LABEL maintainer="Florian Schaper <fschaper@intux.org>"

# copy the palo sources to the container
COPY . /usr/local/src/palo

# update package list and install required libraries for the build environment
# TODO: we don't need all of the boost packages (they come with a lot of baggage)
# then create the build configuration with cmake and start the build
# afterwards install palo and immediatly clean up the build environment to keep
# the image size small.
RUN BUILD_DEPENDENCIES='build-essential cmake libboost-all-dev libicu-dev libssl-dev zlib1g-dev libgoogle-perftools-dev libsvn-dev'; \
    RUNTIME_DEPENDENCIES='libboost-thread1.58.0 libboost-regex1.58.0 libicu55 libssl1.0.0 libtcmalloc-minimal4'; \
    apt-get update \
    && apt-get install --no-install-recommends -y $BUILD_DEPENDENCIES $RUNTIME_DEPENDENCIES \
    && rm -Rf /var/lib/apt/lists/* \
    && cd /usr/local/src/palo \
    && mkdir build \
    && cd build \
    && cmake -G "Unix Makefiles" ../ \
    && make \
    && make install \
    && mv ./usr/bin/palo /usr/local/bin \
    && mv ./usr/lib64/libhttps.palo.so /usr/lib/x86_64-linux-gnu/ \
    && rm -Rf /usr/local/src/palo \
    && apt-get purge -y --auto-remove $BUILD_DEPENDENCIES \
    && mkdir -p /var/lib/palo

# the volume where we will store the palo database
VOLUME /var/lib/palo

# expose port 7777 of the container
EXPOSE 7777

# command to start the server
CMD ["/usr/local/bin/palo","--http","127.0.0.1","7777","--data-directory","/var/lib/palo"]
