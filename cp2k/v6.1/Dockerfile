FROM debian:latest

RUN apt update && apt install -y cp2k

RUN apt-get update && apt-get install vim curl wget lsof openssh-server -y  \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && echo "root:cp2khost" | chpasswd \
    && sed -ri 's@#PermitRootLogin\s+.*@PermitRootLogin yes@' /etc/ssh/sshd_config \
    && sed -ri 's@UsePAM yes@#UsePAM yes@g' /etc/ssh/sshd_config \
    && mkdir -p /var/run/sshd 
    
EXPOSE 22

CMD    ["/usr/sbin/sshd", "-D"]
