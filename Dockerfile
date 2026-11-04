FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y openssh-server sudo python3 && mkdir -p /var/run/sshd
RUN useradd -m -s /bin/bash ansible && echo "ansible:ansible" | chpasswd
RUN echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible && chmod 0440 /etc/sudoers.d/ansible
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
