FROM alpine:latest as source-image

WORKDIR /opt
RUN apk add --no-cache wget tar && \
    wget https://github.com/cp2k/cp2k/releases/download/v2023.1/cp2k-2023.1.tar.bz2 && \
    tar xf cp2k-2023.1.tar.bz2

FROM intel/oneapi-hpckit:2023.0.0-devel-ubuntu22.04 as toolchain-image

# Install requirements for the toolchain.
WORKDIR /opt/cp2k-toolchain
COPY --from=source-image \
     /opt/cp2k-2023.1/tools/toolchain/install_requirements*.sh ./
RUN ./install_requirements.sh ubuntu

# Install the toolchain.
RUN mkdir scripts
COPY --from=source-image \
     /opt/cp2k-2023.1/tools/toolchain/scripts/VERSION \
     /opt/cp2k-2023.1/tools/toolchain/scripts/parse_if.py \
     /opt/cp2k-2023.1/tools/toolchain/scripts/tool_kit.sh \
     /opt/cp2k-2023.1/tools/toolchain/scripts/common_vars.sh \
     /opt/cp2k-2023.1/tools/toolchain/scripts/signal_trap.sh \
     /opt/cp2k-2023.1/tools/toolchain/scripts/get_openblas_arch.sh \
     ./scripts/
COPY --from=source-image \
     /opt/cp2k-2023.1/tools/toolchain/install_cp2k_toolchain.sh .
RUN ./install_cp2k_toolchain.sh \
    --install-all \
    --with-intelmpi \
    --with-mkl \
    --with-libtorch=no \
    --with-sirius=no \
    --dry-run

# Dry-run leaves behind config files for the followup install scripts.
# This breaks up the lengthy installation into smaller docker build steps.
COPY --from=source-image \
     /opt/cp2k-2023.1/tools/toolchain/scripts/stage0/ ./scripts/stage0/
RUN  ./scripts/stage0/install_stage0.sh && rm -rf ./build

COPY --from=source-image \
     /opt/cp2k-2023.1/tools/toolchain/scripts/stage1/ ./scripts/stage1/
RUN  ./scripts/stage1/install_stage1.sh && rm -rf ./build

COPY --from=source-image \
     /opt/cp2k-2023.1/tools/toolchain/scripts/stage2/ ./scripts/stage2/
RUN  ./scripts/stage2/install_stage2.sh && rm -rf ./build

COPY --from=source-image \
     /opt/cp2k-2023.1/tools/toolchain/scripts/stage3/ ./scripts/stage3/
RUN  ./scripts/stage3/install_stage3.sh && rm -rf ./build

COPY --from=source-image \
     /opt/cp2k-2023.1/tools/toolchain/scripts/stage4/ ./scripts/stage4/
RUN  ./scripts/stage4/install_stage4.sh && rm -rf ./build

COPY --from=source-image \
     /opt/cp2k-2023.1/tools/toolchain/scripts/stage5/ ./scripts/stage5/
RUN  ./scripts/stage5/install_stage5.sh && rm -rf ./build

COPY --from=source-image \
     /opt/cp2k-2023.1/tools/toolchain/scripts/stage6/ ./scripts/stage6/
RUN  ./scripts/stage6/install_stage6.sh && rm -rf ./build

COPY --from=source-image \
     /opt/cp2k-2023.1/tools/toolchain/scripts/stage7/ ./scripts/stage7/
RUN  ./scripts/stage7/install_stage7.sh && rm -rf ./build

COPY --from=source-image \
     /opt/cp2k-2023.1/tools/toolchain/scripts/stage8/ ./scripts/stage8/
RUN  ./scripts/stage8/install_stage8.sh && rm -rf ./build

COPY --from=source-image \
     /opt/cp2k-2023.1/tools/toolchain/scripts/arch_base.tmpl \
     /opt/cp2k-2023.1/tools/toolchain/scripts/generate_arch_files.sh \
     ./scripts/
RUN ./scripts/generate_arch_files.sh && rm -rf ./build

# Install CP2K using Linux-intel-x86_64.psmp.
WORKDIR /opt/cp2k
ARG GIT_COMMIT_SHA
COPY --from=source-image /opt/cp2k-2023.1/Makefile .
COPY --from=source-image /opt/cp2k-2023.1/src ./src
COPY --from=source-image /opt/cp2k-2023.1/exts ./exts
COPY --from=source-image /opt/cp2k-2023.1/tools/build_utils ./tools/build_utils
COPY --from=source-image /opt/cp2k-2023.1/arch/Linux-intel-x86_64.psmp /opt/cp2k/arch/
RUN /bin/bash -c " \
    if [ -n "${GIT_COMMIT_SHA}" ] ; then echo "git:\${GIT_COMMIT_SHA::7}" > REVISION; fi && \
    ln -s /opt/cp2k-toolchain /opt/cp2k/tools/toolchain && \
    echo 'Compiling cp2k...' && \
    source /opt/cp2k-toolchain/install/setup && \
    make -j ARCH=Linux-intel-x86_64 VERSION=psmp && \
    ln -sf ./cp2k.psmp ./exe/Linux-intel-x86_64/cp2k && \
    ln -sf ./cp2k_shell.psmp ./exe/Linux-intel-x86_64/cp2k_shell && \
    ln -sf ./graph.psmp ./exe/Linux-intel-x86_64/graph && \
    ln -sf ./dumpdcd.psmp ./exe/Linux-intel-x86_64/dumpdcd && \
    ln -sf ./xyz2dcd.psmp ./exe/Linux-intel-x86_64/xyz2dcd && \
    rm -rf lib obj exe/Linux-intel-x86_64/libcp2k_unittest.psmp"
COPY --from=source-image /opt/cp2k-2023.1/data ./data
COPY --from=source-image /opt/cp2k-2023.1/tests ./tests
COPY --from=source-image /opt/cp2k-2023.1/tools/regtesting ./tools/regtesting

# Run regression tests.
ARG TESTOPTS
RUN /bin/bash -c " \
    source /opt/cp2k-toolchain/install/setup && \
    ./tools/regtesting/do_regtest.py 'Linux-intel-x86_64' 'psmp' "${TESTOPTS}" |& tee regtests.log && \
    rm -rf regtesting"

# Setup entry point for production.
COPY --from=source-image /opt/cp2k-2023.1/tools/docker/scripts/prod_entrypoint.sh ./
WORKDIR /mnt
ENTRYPOINT ["/opt/cp2k/prod_entrypoint.sh", "Linux-intel-x86_64", "psmp"]
CMD ["cp2k", "--help"]

#EOF