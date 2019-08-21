FROM pytorch/pytorch:1.1.0-cuda10.0-cudnn7.5-runtime
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list &&\
    apt clean && apt update && apt install git
RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ &&\
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ &&\
    conda config --set show_channel_urls yes &&\
    conda install scikit-learn notebook
RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple pymatgen
RUN cd /workspace && git clone https://github.com/txie-93/cgcnn.git
WORKDIR /workspace/cgcnn
ENV PATH /opt/conda/bin:$PATH
CMD ["/opt/conda/bin/jupyter-notebook", "--ip='0.0.0.0'", "--port=8888", "--NotebookApp.password='sha1:f0bbd0a46531:91313b65013c9b6f4a9b2521be7594a48195cfc4'", "--allow-root"]
