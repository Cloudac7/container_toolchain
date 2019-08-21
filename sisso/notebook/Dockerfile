FROM ironmerchant/openmpi
RUN yum makecache && yum install -y git
RUN cd /root && git clone https://github.com/rouyang2017/SISSO.git && \
    cd SISSO/src && mpifort -O2 var_global.f90 libsisso.f90 DI.f90 FC.f90 SISSO.f90 -o /usr/bin/SISSO
RUN curl -o ~/miniconda.sh -O  https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh &&\
    /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ &&\
    /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ &&\
    /opt/conda/bin/conda config --set show_channel_urls yes &&\
    /opt/conda/bin/conda install -y python=3.6 notebook && \
    /opt/conda/bin/conda clean -ya
ENV PATH /opt/conda/bin:$PATH
CMD ["/opt/conda/bin/jupyter-notebook", "--ip='0.0.0.0'", "--port=8888", "--NotebookApp.password='sha1:f0bbd0a46531:91313b65013c9b6f4a9b2521be7594a48195cfc4'", "--allow-root"]
