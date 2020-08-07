FROM debian:10 as unpacker

ENV BLENDER_PACKAGE https://download.blender.org/release/Blender2.79/blender-2.79-linux-glibc219-x86_64.tar.bz2

ADD \
  $BLENDER_PACKAGE \
  /blender.tar.bz2

RUN apt-get update \
  && apt-get install -y bzip2 \
  && mkdir /blender \
  && tar xvf /blender.tar.bz2 --strip=1 -C /blender/

# Fix T56938, T54222: network render broken pipe errors.
# https://developer.blender.org/rBAf975292b1ec103826fe244dfdb851fed0428b624
ADD \
  0001-Fix-T56938-T54222-network-render-broken-pipe-errors.patch \
  /netrender-broken-pipe.patch
RUN apt-get install -y patch \
  && cd /blender/2.79/scripts/addons \
  && patch -p1 < /netrender-broken-pipe.patch

FROM debian:10

RUN apt-get update \
  && apt-get install -y \
    libglu1-mesa \
    libxi6 \
    libgconf-2-4 \
    libxrender1

WORKDIR /blender

COPY --from=unpacker /blender /blender

COPY ./renderServerStartup.py .

RUN ls /blender

CMD ./blender -b -P ./renderServerStartup.py
