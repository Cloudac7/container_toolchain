FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04
LABEL maintainer "yfb deepmd-kit  yuanfengbo888@pku.edu.cn"

# Install dependencies
RUN apt-get update \
  && apt-get -y install git wget \
  && apt-get -y install pkg-config zip  zlib1g-dev unzip \
  && apt install -y mpich  \
  && apt-get -y  install cmake  \
  && wget https://github.com/bazelbuild/bazel/releases/download/0.16.1/bazel-0.16.1-installer-linux-x86_64.sh \
  && apt-get -y install g++ \
  && git clone https://github.com/tensorflow/tensorflow.git -b r1.8 \
  && git clone -b stable https://github.com/lammps/lammps.git /lammps-stable \
  && git clone https://github.com/deepmodeling/deepmd-kit.git /deepmd-kit \
  && apt-get -y install python3   \
  && apt-get -y install python3-pip \
  && apt-get -y remove python2.7 \
  && ln -s /usr/bin/python3 /usr/bin/python \
  && ln -s /usr/bin/pip3 /usr/bin/pip  \
  && pip install numpy 


RUN  chmod +x bazel-0.16.1-installer-linux-x86_64.sh \
  && ./bazel-0.16.1-installer-linux-x86_64.sh --prefix=/usr \
  && bazel version

RUN cd / && git clone https://github.com/NVIDIA/nccl.git -b v2.4.2-1  && cd nccl  \
  && make CUDA_HOME=/usr/local/cuda -j NVCC_GENCODE="-gencode=arch=compute_70,code=sm_70"  \
  && make PREFIX=/usr/local/cuda install \
  && cp /usr/local/cuda-9.0/LICENSE /usr/local/cuda-9.0/NCCL-SLA.txt \
  && cp /usr/local/cuda-9.0/LICENSE /usr/local/cuda-9.0/targets/x86_64-linux/NCCL-SLA.txt

RUN export LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:/usr/local/lib:/usr/local/cuda/lib:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH \
  && ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 \
  && cd /tensorflow \
  && /bin/echo -e "\n\ny\nn\nn\nn\nn\nn\nn\nn\nn\ny\n9.0\n\n7.0\n\nn\n2.4.2\n\n3.5,5.2,6.0,6.1,7.0\nn\n\nn\n\n">install_input \
  && ./configure <install_input  \
  && bazel build -c opt --config=cuda //tensorflow/tools/pip_package:build_pip_package  --action_env="LD_LIBRARY_PATH=${LD_LIBRARY_PATH}" \
  && bazel build -c opt //tensorflow:libtensorflow_cc.so --action_env="LD_LIBRARY_PATH=${LD_LIBRARY_PATH}" 
RUN  ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg 
RUN  pip install /tmp/tensorflow_pkg/tensorflow-*.whl
RUN mkdir /tensorflow_root \
  && mkdir /deepmd_root \
  && export deepmd_root="/deepmd_root" \
  && export tensorflow_root="/tensorflow_root" \
  && mkdir $tensorflow_root/lib \
  && mkdir $tensorflow_root/include \
  && cp bazel-bin/tensorflow/libtensorflow_cc.so $tensorflow_root/lib/ \
  && cp bazel-bin/tensorflow/libtensorflow_framework.so $tensorflow_root/lib/ \
  && cp -r bazel-genfiles/* $tensorflow_root/include \
  && cp -r tensorflow/cc $tensorflow_root/include/tensorflow \
  && cp -r tensorflow/core $tensorflow_root/include/tensorflow \
  && cp -r third_party $tensorflow_root/include  \
  && cp -r /root/.cache/bazel/_bazel_root/*/external/protobuf_archive/src/* $tensorflow_root/include \
  && cp -r /root/.cache/bazel/_bazel_root/*/external/eigen_archive/* $tensorflow_root/include

WORKDIR  /deepmd-kit/source/make
RUN  export deepmd_root="/deepmd_root" \
  && export tensorflow_root="/tensorflow_root" \
  && cmake -DTF_GOOGLE_BIN=0 -DTENSORFLOW_ROOT=$tensorflow_root -DCMAKE_INSTALL_PREFIX=$deepmd_root .. \
  && make \
  && make install \
  && make lammps

WORKDIR /deepmd-kit/examples/train
RUN sed  's/\("stop_batch":\).*/\11000,/g'  water_smth.json >water_smth_test.json \
  && /deepmd_root/bin/dp_train water_smth_test.json \
  && /deepmd_root/bin/dp_frz \
  && cp /deepmd-kit/examples/train/frozen_model.pb /deepmd-kit/examples/lmp


WORKDIR /lammps-stable/src
RUN cp -r  /deepmd-kit/source/make/USER-DEEPMD /lammps-stable/src/ \
  && make yes-user-deepmd \
  && make mpi -j4

WORKDIR /deepmd-kit/examples/lmp
RUN /lammps-stable/src/lmp_mpi -i lammps.in

WORKDIR /tensorflow
RUN ln -s /deepmd_root/bin/dp_train /usr/bin/dp_train \
  && ln -s /deepmd_root/bin/dp_frz /usr/bin/dp_frz \
  && ln -s /deepmd_root/bin/dp_test /usr/bin/dp_test \
  && ln -s /deepmd_root/bin/dp_ipi /usr/bin/dp_ipi \
  && mv /lammps-stable/src/lmp_mpi /usr/bin
RUN bazel clean \
  && rm -rf /root/.cache \
  && rm -rf /lammps-stable \
  && rm -rf /bazel-*-installer-linux-x86_64.sh \
  && rm -rf /tensorflow \
  && rm -rf /usr/bin/bazel \
  && rm -rf /usr/lib/bazel \
  && rm -rf /tmp
COPY Dockerfile ./

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:deepmdhost' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
