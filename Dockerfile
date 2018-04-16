FROM ubuntu_16_04-base
LABEL Description="Aporeto's ubuntu_16_04-atb Image" Vendor="Aporeto"

# Setup user
RUN useradd -ms /bin/bash apotests && usermod -aG sudo apotests && \
  echo "apotests ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Get all deps
RUN apt-get update && apt-get install -y \
  apache2-utils \
  build-essential \
  conntrack \
  libelf-dev \
  libnetfilter-queue-dev \
  npm \
  python-pip \
  time

# Setup nodejs
RUN npm install \
  http-server \
  -g && \
  ln -s /usr/bin/nodejs /usr/bin/node

# Get docker and configure files
RUN curl -sSL https://get.docker.com/ | sh && \
  pip install docker-compose && \
  systemctl enable docker && \
  usermod -aG docker apotests && \
  sudo sed -i -e 's/ExecStart=\/usr\/bin\/dockerd -H fd:\/\//ExecStart=\/usr\/bin\/dockerd --userland-proxy=false -H fd:\/\//g' /lib/systemd/system/docker.service

# Misc setup
RUN sudo sed -i -e 's/#MaxStartups 10:30:60/MaxSessions 10000\n#MaxStartups 10:30:60/g' /etc/ssh/sshd_config && \
  mkdir -p /home/apotests/.ssh && \
  touch /home/apotests/.bash_profile && \
  touch /home/apotests/.cloud-warnings.skip
ADD authorized_keys /home/apotests/.ssh/authorized_keys

