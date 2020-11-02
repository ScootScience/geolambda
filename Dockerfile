FROM lambci/lambda:build-provided
# FROM ubuntu:bionic

LABEL maintainer="Scoot Science/Connor Dibble <connor.dibble@scootscience.com>"
LABEL authors="Connor Dibble  <connor.dibble@scootscience.com>"

# install system libraries
RUN \
    # apt update && \
    # apt-get install --assume-yes libeccodes0 libeccodes0-dev zip binutils rsync libbz2-dev software-properties-common && \
    # add-apt-repository ppa:george-edison55/cmake-3.18 \
    # apt-get update \ 
    # apt install --assume-yes build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget python3.6 python3-pip && \
    # pip3 install cfgrib eccodes-python eccodes
    yum makecache fast; \
    yum-config-manager --enable epel; \
    yum install -y wget libpng-devel nasm unzip netcdf-devel.x86_64; \
    yum install -y bash-completion --enablerepo=epel; \
    yum install -y \
    rsync \
    chrpath \
    zip \
    gcc \
    git \
    jasper-devel \
    jasper-libs \
    openjpeg2-tools \
    openjpeg2-devel \ 
    openjpeg2 \
    python36 \
    python36-pip \
    python36-devel; \
    yum clean -y all; \
    yum remove -y cmake; \
    yum autoremove -y

# RUN yum -y install  \
#     cmake \
#     chrpath \
#     gcc \
#     git \
#     jasper-devel \
#     jasper-libs \
#     openjpeg2-tools \
#     openjpeg2-devel \ 
#     openjpeg2 \
#     python36 \
#     python36-pip \
#     python36-devel \
#     wget \
#     zip \
#     && yum clean all

# versions of packages
ENV \
#     GDAL_VERSION=3.0.1 \
#     PROJ_VERSION=6.2.0 \
#     GEOS_VERSION=3.8.0 \
#     GEOTIFF_VERSION=1.5.1 \
#     HDF4_VERSION=4.2.14 \
#     HDF5_VERSION=1.10.5 \
#     NETCDF_VERSION=4.7.1 \
#     NGHTTP2_VERSION=1.39.2 \
#     OPENJPEG_VERSION=2.3.1 \
#     CURL_VERSION=7.66.0 \
#     LIBJPEG_TURBO_VERSION=2.0.3 \
#     PKGCONFIG_VERSION=0.29.2 \
    LIBECCODES_VERSION=2.19.0
#     SZIP_VERSION=2.1.1 \
#     WEBP_VERSION=1.0.3 \
#     ZSTD_VERSION=1.4.3 \
    # OPENSSL_VERSION=1.0.2

# Paths to things
ENV \
    BUILD=/build \
    NPROC=4 \
    PREFIX=/usr/local \
    GDAL_CONFIG=/usr/local/bin/gdal-config \
    LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64 \
    PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig:/usr/lib64/pkgconfig \
    GDAL_DATA=${PREFIX}/share/gdal \
    PROJ_LIB=${PREFIX}/share/proj

# switch to a build directory
WORKDIR /build

# Upgrade cmake by installing from source
# RUN \
#     mkdir cmake; \
#     wget -qO- https://cmake.org/files/v3.18/cmake-3.18.0.tar.gz \
#         | tar -xzv -C cmake --strip-components=1; cd cmake; \
#     ./bootstrap \
#     make; \
#     make install; \
#     # installed into /usr/local/bin/.cmake
#     # make -j ${NPROC} install ; \
#     cd ../; rm -rf cmake

RUN wget https://github.com/Kitware/CMake/releases/download/v3.17.2/cmake-3.17.2-Linux-x86_64.sh \
    -q -O /tmp/cmake-install.sh \
    && chmod u+x /tmp/cmake-install.sh \
    && mkdir /usr/bin/cmake \
    && /tmp/cmake-install.sh --skip-license --prefix=/usr/bin/cmake \
    && rm /tmp/cmake-install.sh

ENV PATH="/usr/bin/cmake/bin:${PATH}"

# wget https://cmake.org/files/v3.18/cmake-3.18.0.tar.gz
# tar -xvzf cmake-3.18.0.tar.gz
# cd cmake-3.18.0
# ./bootstrap
# make
# sudo make install

# Install ECCODES library - try 1
# RUN \
#     mkdir libeccodes0; \
#     wget -qO- https://confluence.ecmwf.int/download/attachments/45757960/eccodes-2.19.0-Source.tar.gz?api=v2 \
#         | tar -xzv -C libeccodes0 --strip-components=1; cd libeccodes0; \
#     # ./configure --prefix=$PREFIX ; \
#     cmake -DCMAKE_INSTALL_PREFIX={$PREFIX}/libeccodes0/eccodes-2.19.0-Source; \
#     make ; \
#     make -j ${NPROC} install; \
#     # ctest; \
#     # make install ; \
#     cd ../; rm -rf libeccodes0

# try 2 - works but doesn't copy over; from here https://github.com/kilobike/eccodes-docker
# RUN mkdir eccodes \
#     && cd eccodes \
#     && mkdir build \
#     # && cd build \
#     # && wget -O eccodes_test_data.tar.gz  "http://download.ecmwf.org/test-data/grib_api/eccodes_test_data.tar.gz" \
#     # && tar -xzf eccodes_test_data.tar.gz \
#     # && rm eccodes_test_data.tar.gz \
#     # && cd /eccodes \
#     && wget -O eccodes.tar.gz "https://software.ecmwf.int/wiki/download/attachments/45757960/eccodes-2.0.2-Source.tar.gz?api=v2" \
#     && tar -xzf eccodes.tar.gz \
#     && cd build \
#     && pwd \
#     && cmake -DCMAKE_INSTALL_PREFIX=/usr/local/eccodes -DENABLE_NETCDF=OFF -DENABLE_MEMFS=ON -DENABLE_PNG=ON ../eccodes-2.0.2-Source \
#     && make \
#     # && ctest \
#     && make install \
#     && pwd \
#     && rm -rf /eccodes

# thrid try
RUN python3.6 -m pip install numpy cfgrib pyeccodes

WORKDIR /tmp

ENV ECCODES_URL=https://software.ecmwf.int/wiki/download/attachments/45757960 \
    ECCODES_VERSION=eccodes-2.10.0-Source

RUN cd /tmp && wget --output-document=${ECCODES_VERSION}.tar.gz ${ECCODES_URL}/${ECCODES_VERSION}.tar.gz?api=v2 && tar -zxvf ${ECCODES_VERSION}.tar.gz

RUN cd ${ECCODES_VERSION} && mkdir build && cd build && \
    cmake -DENABLE_FORTRAN=false -DPYTHON_LIBRARY_DIR=/usr/lib64/python3.6 -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m -DPYTHON_EXECUTABLE=/usr/bin/python3  .. \
    && make -j2 && make install \
    && cd python3 && python3 setup.py install

WORKDIR /lambda_root

RUN cp -r /usr/local/lib64/python3.6/site-packages/eccodes /usr/local/lib64/python3.6/site-packages/numpy /usr/local/lib64/python3.6/site-packages/gribapi . && \
    mv /usr/local/lib/libeccodes.so gribapi/ && \
    chrpath -r '$ORIGIN' gribapi/_gribapi_swig.cpython-36m-x86_64-linux-gnu.so

COPY create_deployment.sh /usr/local/bin/

# tar -xzf  eccodes-x.y.z-Source.tar.gz
# mkdir build ; cd build
# cmake -DCMAKE_INSTALL_PREFIX=/path/to/where/you/install/eccodes ../eccodes-x.y.z-Source
# make
# ctest
# make install

# pkg-config - version > 2.5 required for GDAL 2.3+
# RUN \
#     mkdir pkg-config; \
#     wget -qO- https://pkg-config.freedesktop.org/releases/pkg-config-$PKGCONFIG_VERSION.tar.gz \
#         | tar xvz -C pkg-config --strip-components=1; cd pkg-config; \
#     ./configure --prefix=$PREFIX CFLAGS="-O2 -Os"; \
#     make -j ${NPROC} install; \
#     cd ../; rm -rf pkg-config

# # proj
# RUN \
#     mkdir proj; \
#     wget -qO- http://download.osgeo.org/proj/proj-$PROJ_VERSION.tar.gz | tar xvz -C proj --strip-components=1; cd proj; \
#     ./configure --prefix=$PREFIX; \
#     make -j ${NPROC} install; \
#     cd ..; rm -rf proj

# # nghttp2
# RUN \
#     mkdir nghttp2; \
#     wget -qO- https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.gz \
#         | tar xvz -C nghttp2 --strip-components=1; cd nghttp2; \
#     ./configure --enable-lib-only --prefix=${PREFIX}; \
#     make -j ${NPROC} install; \
#     cd ..; rm -rf nghttp2

# # curl
# RUN \
#     mkdir curl; \
#     wget -qO- https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz \
#         | tar xvz -C curl --strip-components=1; cd curl; \
#     ./configure --prefix=${PREFIX} --disable-manual --disable-cookies --with-nghttp2=${PREFIX}; \
#     make -j ${NPROC} install; \
#     cd ..; rm -rf curl

# # GEOS
# RUN \
#     mkdir geos; \
#     wget -qO- http://download.osgeo.org/geos/geos-$GEOS_VERSION.tar.bz2 \
#         | tar xvj -C geos --strip-components=1; cd geos; \
#     ./configure --enable-python --prefix=$PREFIX CFLAGS="-O2 -Os"; \
#     make -j ${NPROC} install; \
#     cd ..; rm -rf geos

# # szip (for hdf)
# RUN \
#     mkdir szip; \
#     wget -qO- https://support.hdfgroup.org/ftp/lib-external/szip/$SZIP_VERSION/src/szip-$SZIP_VERSION.tar.gz \
#         | tar xvz -C szip --strip-components=1; cd szip; \
#     ./configure --prefix=$PREFIX; \
#     make -j ${NPROC} install; \
#     cd ..; rm -rf szip

# # libhdf4
# RUN \
#     mkdir hdf4; \
#     wget -qO- https://support.hdfgroup.org/ftp/HDF/releases/HDF$HDF4_VERSION/src/hdf-$HDF4_VERSION.tar \
#         | tar xv -C hdf4 --strip-components=1; cd hdf4; \
#     ./configure \
#         --prefix=$PREFIX \
#         --with-szlib=$PREFIX \
#         --enable-shared \
#         --disable-netcdf \
#         --disable-fortran; \
#     make -j ${NPROC} install; \
#     cd ..; rm -rf hdf4

# # libhdf5
# RUN \
#     mkdir hdf5; \
#     wget -qO- https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${HDF5_VERSION%.*}/hdf5-${HDF5_VERSION}/src/hdf5-$HDF5_VERSION.tar.gz \
#         | tar xvz -C hdf5 --strip-components=1; cd hdf5; \
#     ./configure \
#         --prefix=$PREFIX \
#         --with-szlib=$PREFIX; \
#     make -j ${NPROC} install; \
#     cd ..; rm -rf hdf5

# # NetCDF
# RUN \
#     mkdir netcdf; \
#     wget -qO- https://github.com/Unidata/netcdf-c/archive/v$NETCDF_VERSION.tar.gz \
#         | tar xvz -C netcdf --strip-components=1; cd netcdf; \
#     ./configure --prefix=$PREFIX --enable-hdf4; \
#     make -j ${NPROC} install; \
#     cd ..; rm -rf netcdf

# # WEBP
# RUN \
#     mkdir webp; \
#     wget -qO- https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${WEBP_VERSION}.tar.gz \
#         | tar xvz -C webp --strip-components=1; cd webp; \
#     CFLAGS="-O2 -Wl,-S" PKG_CONFIG_PATH="/usr/lib64/pkgconfig" ./configure --prefix=$PREFIX; \
#     make -j ${NPROC} install; \
#     cd ..; rm -rf webp

# # ZSTD
# RUN \
#     mkdir zstd; \
#     wget -qO- https://github.com/facebook/zstd/archive/v${ZSTD_VERSION}.tar.gz \
#         | tar -xvz -C zstd --strip-components=1; cd zstd; \
#     make -j ${NPROC} install PREFIX=$PREFIX ZSTD_LEGACY_SUPPORT=0 CFLAGS=-O1 --silent; \
#     cd ..; rm -rf zstd

# # openjpeg
# RUN \
#     mkdir openjpeg; \
#     wget -qO- https://github.com/uclouvain/openjpeg/archive/v$OPENJPEG_VERSION.tar.gz \
#         | tar xvz -C openjpeg --strip-components=1; cd openjpeg; mkdir build; cd build; \
#     cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX; \
#     make -j ${NPROC} install; \
#     cd ../..; rm -rf openjpeg

# # jpeg_turbo
# RUN \
#     mkdir jpeg; \
#     wget -qO- https://github.com/libjpeg-turbo/libjpeg-turbo/archive/${LIBJPEG_TURBO_VERSION}.tar.gz \
#         | tar xvz -C jpeg --strip-components=1; cd jpeg; \
#     cmake -G"Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$PREFIX .; \
#     make -j $(nproc) install; \
#     cd ..; rm -rf jpeg

# # geotiff
# RUN \
#     mkdir geotiff; \
#     wget -qO- https://download.osgeo.org/geotiff/libgeotiff/libgeotiff-$GEOTIFF_VERSION.tar.gz \
#         | tar xvz -C geotiff --strip-components=1; cd geotiff; \
#     ./configure --prefix=${PREFIX} \
#         --with-proj=${PREFIX} --with-jpeg=${PREFIX} --with-zip=yes;\
#     make -j ${NPROC} install; \
#     cd ${BUILD}; rm -rf geotiff

# # GDAL
# RUN \
#     mkdir gdal; \
#     wget -qO- http://download.osgeo.org/gdal/$GDAL_VERSION/gdal-$GDAL_VERSION.tar.gz \
#         | tar xvz -C gdal --strip-components=1; cd gdal; \
#     ./configure \
#         --disable-debug \
#         --disable-static \
#         --prefix=${PREFIX} \
#         --with-openjpeg \
#         --with-geotiff=${PREFIX} \
#         --with-hdf4=${PREFIX} \
#         --with-hdf5=${PREFIX} \
#         --with-netcdf=${PREFIX} \
#         --with-webp=${PREFIX} \
#         --with-zstd=${PREFIX} \
#         --with-jpeg=${PREFIX} \
#         --with-threads=yes \
#         --with-curl=${PREFIX}/bin/curl-config \
#         --without-python \
#         --without-libtool \
#         --with-geos=$PREFIX/bin/geos-config \
#         --with-hide-internal-symbols=yes \
#         CFLAGS="-O2 -Os" CXXFLAGS="-O2 -Os" \
#         LDFLAGS="-Wl,-rpath,'\$\$ORIGIN'"; \
#     make -j ${NPROC} install; \
#     cd ${BUILD}; rm -rf gdal

# # Open SSL is needed for building Python so it's included here for ease
# RUN \
#     mkdir openssl; \
#     wget -qO- https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
#         | tar xvz -C openssl --strip-components=1; cd openssl; \
#     ./config shared --prefix=${PREFIX}/openssl --openssldir=${PREFIX}/openssl; \
#     make depend; make install; cd ..; rm -rf openssl


# Copy shell scripts and config files over
# COPY bin/* /usr/local/bin/

WORKDIR /home/geolambda
