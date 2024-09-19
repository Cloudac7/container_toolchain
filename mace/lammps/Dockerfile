FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04 as compile-image
ARG DEBIAN_FRONTEND=noninteractive

# prepairing environment
RUN apt-get update && \
    apt-get install -y git wget gawk libopenblas-base libgomp1 make cmake \
    openssh-client python3 python3-dev python3-venv mpich libmpich-dev vim \
    zlib1g zlib1g-dev gcc gfortran g++ libopenblas-dev xxd zip unzip tar && \
    rm -rf /var/lib/apt/lists/*

# download and install libtorch
WORKDIR /opt
RUN wget https://download.pytorch.org/libtorch/cu121/libtorch-shared-with-deps-2.2.0%2Bcu121.zip && \
    unzip libtorch-shared-with-deps-2.2.0+cu121.zip && \
    rm libtorch-shared-with-deps-2.2.0+cu121.zip

ENV LIBTORCH=/opt/libtorch

# download and compile lammps
WORKDIR /tmp
RUN git clone --branch=mace --depth=1 https://github.com/ACEsuit/lammps && \
    lammps_installation_dir=/opt/lammps && \
    cd lammps && \
    mkdir build && cd build && \
    export PATH=/usr/local/bin:/usr/bin:$PATH && \
    cmake \
        -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_INSTALL_PREFIX=${lammps_installation_dir} \
        -D CMAKE_CXX_STANDARD=17 \
        -D CMAKE_CXX_STANDARD_REQUIRED=ON \
        -D BUILD_MPI=ON -D BUILD_OMP=yes -D LAMMPS_MACHINE=mpi \
        -D BUILD_SHARED_LIBS=ON \
        -D PKG_KOKKOS=ON \
        -D Kokkos_ENABLE_CUDA=ON \
        -D CMAKE_CXX_COMPILER=../lib/kokkos/bin/nvcc_wrapper \
        -D Kokkos_ARCH_AMDAVX=ON \
        -D Kokkos_ARCH_AMPERE100=ON \
        -D CMAKE_PREFIX_PATH=/opt/libtorch \
        -D PKG_ML-MACE=ON \
        ../cmake && \
    make -j 4 && make install && \
    cd ../../ && rm -rf lammps*
ENV PATH="/opt/lammps/bin:$PATH"
ENV LIBRARY_PATH="/opt/lammps/lib:$LIBRARY_PATH"
ENV LD_LIBRARY_PATH="/opt/lammps/lib:/opt/deepmd-kit/lib:$LD_LIBRARY_PATH"

FROM nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu22.04 as build-image
COPY --from=compile-image /opt /opt
RUN apt-get update && \
    apt-get install -y libopenblas-base libgomp1 python3 \
    mpich zlib1g gcc gfortran g++ xxd  && \
    rm -rf /var/lib/apt/lists/*
ENV PATH="/opt/lammps/bin:$PATH"
ENV LIBRARY_PATH="/opt/lammps/lib:/opt/libtorch/lib:$LIBRARY_PATH"
ENV LD_LIBRARY_PATH="/opt/lammps/lib:/opt/libtorch/lib:$LD_LIBRARY_PATH"

CMD ["/bin/bash"]
