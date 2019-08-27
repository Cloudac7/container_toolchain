FROM cloudac7/deepmd-kit:cuda-9.0-centos7
ENV PATH /opt/conda3/bin:$PATH
RUN echo "export PATH=/opt/conda3/bin:$PATH" >> /root/.bashrc

RUN yum install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:deepmdhost' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN ssh-keygen -A
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
