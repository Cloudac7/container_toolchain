FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
ARG PYTHON_VERSION=3.6
RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         ca-certificates \
         libjpeg-dev \
         libpng-dev && \
     rm -rf /var/lib/apt/lists/*


RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh && \
     /opt/conda/bin/conda install -y python=$PYTHON_VERSION tensorflow-gpu=1.13 && \
     /opt/conda/bin/conda install -y notebook pymatgen tqdm -c anaconda -c matsci && \
     /opt/conda/bin/conda clean -ya
ENV PATH /opt/conda/bin:$PATH


WORKDIR /workplace
RUN chmod -R a+x .
RUN cd /workplace && git clone https://github.com/txie-93/gdynet.git
WORKDIR /workplace/gdynet
CMD ["/opt/conda/bin/jupyter-notebook", "--ip='0.0.0.0'", "--port=8888", "--NotebookApp.password='sha1:f0bbd0a46531:91313b65013c9b6f4a9b2521be7594a48195cfc4'", "--allow-root"]
