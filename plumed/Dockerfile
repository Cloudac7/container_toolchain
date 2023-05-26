FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04 as compile-image
ARG DEBIAN_FRONTEND=noninteractive

# prepairing environment
RUN apt-get update && \
    apt-get install -y git wget gawk libopenblas-base libgomp1 make cmake \
    openssh-client python3 python3-dev python3.8-venv mpich vim zlib1g \
    gcc gfortran g++ libopenblas-dev xxd zlib1g-dev zip unzip tar && \
    rm -rf /var/lib/apt/lists/*

# download and install libtorch
WORKDIR /opt
RUN wget https://download.pytorch.org/libtorch/cu117/libtorch-cxx11-abi-shared-with-deps-2.0.1%2Bcu117.zip && \
    unzip libtorch-cxx11-abi-shared-with-deps-2.0.1+cu117.zip && \
    rm libtorch-cxx11-abi-shared-with-deps-2.0.1+cu117.zip
ENV LIBTORCH=/opt/libtorch
ENV CPATH="${LIBTORCH}/include/torch/csrc/api/include/:${LIBTORCH}/include/:${LIBTORCH}/include/torch:$CPATH"
ENV INCLUDE="${LIBTORCH}/include/torch/csrc/api/include/:${LIBTORCH}/include/:${LIBTORCH}/include/torch:$INCLUDE"
ENV LIBRARY_PATH="${LIBTORCH}/lib:$LIBRARY_PATH"
ENV LD_LIBRARY_PATH="${LIBTORCH}/lib:$LD_LIBRARY_PATH"

# download and compile plumed
WORKDIR /tmp/plumed
RUN wget https://github.com/plumed/plumed2/releases/download/v2.9.0/plumed-2.9.0.tgz && \
    tar xf plumed-2.9.0.tgz && \
    cd plumed-2.9.0 && \
    export CC=`which gcc` && export CXX=`which g++` && export FC=`which gfortran` && \
    ./configure --prefix=/opt/plumed --enable-libtorch --enable-modules=all CXXFLAGS=-O3 && \
    make -j 6 && \
    make install && \
    cd .. && \
    rm -fr plumed-2.9.0 plumed-2.9.0.tgz
ENV PATH="/opt/plumed/bin:$PATH"
ENV INCLUDE="/opt/plumed/include:$INCLUDE"
ENV LIBRARY_PATH="/opt/plumed/lib:$LIBRARY_PATH"
ENV LD_LIBRARY_PATH="/opt/plumed/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/opt/plumed/lib/pkgconfig:$PKG_CONFIG_PATH"

# download and compile lammps
WORKDIR /tmp
RUN wget https://github.com/lammps/lammps/archive/refs/tags/stable_23Jun2022_update4.tar.gz && \
    lammps_installation_dir=/opt/lammps && \
    tar xf stable_23Jun2022_update4.tar.gz && \
    cd lammps-stable_23Jun2022_update4 && \
    sed -i "80,82d" src/PLUMED/fix_plumed.cpp && \
    mkdir build && cd build && \
    export PATH=/usr/local/bin:/usr/bin:$PATH && \
    cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_Fortran_COMPILER=gfortran \
    -D BUILD_MPI=yes -D BUILD_OMP=yes -D LAMMPS_MACHINE=mpi \
    -D BUILD_SHARED_LIBS=yes \
    -D CMAKE_INSTALL_PREFIX=${lammps_installation_dir} \
    -D CMAKE_INSTALL_LIBDIR=lib \
    -D CMAKE_INSTALL_FULL_LIBDIR=${lammps_installation_dir}/lib \
    -C ../cmake/presets/most.cmake -C ../cmake/presets/nolib.cmake \
    -D PKG_PLUMED=yes -D PLUMED_MODE=shared ../cmake && \
    make -j 6 && make install && \
    cd ../../ && rm -rf lammps-* && rm stable_23Jun2022_update4.tar.gz
ENV PATH="/opt/lammps/bin:$PATH"
ENV LIBRARY_PATH="/opt/lammps/lib:$LIBRARY_PATH"
ENV LD_LIBRARY_PATH="/opt/lammps/lib:/opt/deepmd-kit/lib:$LD_LIBRARY_PATH"

# install deepmd-kit
RUN python3 -m venv /opt/deepmd-kit
ENV PATH="/opt/deepmd-kit/bin:$PATH"
WORKDIR /tmp
RUN pip install --no-cache-dir tensorflow==2.12 && \
    wget https://github.com/lammps/lammps/archive/refs/tags/stable_23Jun2022_update4.tar.gz && \
    tar xf stable_23Jun2022_update4.tar.gz && \
    git clone https://github.com/deepmodeling/deepmd-kit.git -b v2.2.2 --recursive --depth=1 && \
    cd deepmd-kit && \
    pip install --no-cache-dir . && \
    export CC=`which gcc` && export CXX=`which g++` && export FC=`which gfortran` && export DP_VARIANT=cuda && \
    cd source && \
    mkdir build && cd build && \
    cmake -DUSE_TF_PYTHON_LIBS=TRUE \
    -DCMAKE_INSTALL_PREFIX=/opt/deepmd-kit \
    -DLAMMPS_SOURCE_ROOT=/tmp/lammps-stable_23Jun2022_update4 \
    -DUSE_CUDA_TOOLKIT=TRUE .. && \
    make && \
    make install && \
    cd ../.. && \
    rm -rf *

FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu20.04 as build-image
COPY --from=compile-image /opt /opt
ENV PATH="/opt/lammps/bin:/opt/plumed/bin:/opt/deepmd-kit/bin:$PATH"
ENV CPATH="/opt/libtorch/include/torch/csrc/api/include/:/opt/libtorch/include/:/opt/libtorch/include/torch:$CPATH"
ENV INCLUDE="/opt/plumed/include:/opt/libtorch/include/torch/csrc/api/include/:/opt/libtorch/include/:/opt/libtorch/include/torch:$INCLUDE"
ENV LIBRARY_PATH="/opt/lammps/lib:/opt/libtorch/lib:/opt/plumed/lib:$LIBRARY_PATH"
ENV LD_LIBRARY_PATH="/opt/lammps/lib:/opt/deepmd-kit/lib:/opt/plumed/lib:/opt/libtorch/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/opt/plumed/lib/pkgconfig:$PKG_CONFIG_PATH"
ENV LAMMPS_PLUGIN_PATH="/opt/deepmd-kit/lib/deepmd_lmp"

CMD ["/bin/bash"]
