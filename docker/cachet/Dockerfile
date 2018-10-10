FROM centos/systemd

# Install systemd -- See https://hub.docker.com/_/centos/
RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs && \
    (                                                         \
      cd /lib/systemd/system/sysinit.target.wants/ ;          \
      for i in *; do                                          \
        [ $i == systemd-tmpfiles-setup.service ] || rm -f $i ;\
     done                                                     \
    )
RUN rm -f /etc/systemd/system/*.wants/*;               \
    rm -f /lib/systemd/system/basic.target.wants/* ;    \
    rm -f /lib/systemd/system/anaconda.target.wants/* ;  \
    rm -f /lib/systemd/system/local-fs.target.wants/* ;   \
    rm -f /lib/systemd/system/multi-user.target.wants/* ;  \
    rm -f /lib/systemd/system/sockets.target.wants/*udev* ; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl* ;

# Install Ansible and Packages
RUN yum -y update ;                 \
    yum -y install memcached        \
    httpd telnet openssl vim        \
    gcc git sudo unzip zlib-devel   \
    python-psycopg2  python-devel   \
    python-setuptools ibffi-devel   \
    php71w php71w-pecl-memcached    \
    php71w-mysql php71w-mbstring    \
    php71w-cli php71w-simplexml     \
    php71w-dom php71w-openssl       \
    php71w-xml php71w-mcrypt        \
    php71w-gd php71w-tokenizer      \
    php71w-pgsql postgresql-libs    \
    postgresql postgresql-server    \
    postgresql-contrib epel-release \
    libsemanage-pythonopenssl-devel \
    https://mirror.webtatic.com/yum/el7/webtatic-release.rpm \
    yum clean all       ;\
    yum -y upgrade      ;\
    easy_install pip    ;\
    pip install ansible ;\
    systemctl enable httpd.service

# Set root password
RUN echo "root:Docker!" | chpasswd

# Locale. Needed for postgres. Centos does not have locale-gen, the equivalent command is localedef.
RUN localedef -c -f UTF-8 -i en_US en_US.UTF-8 ;\
    localedef -c -f UTF-8 -i ja_JP ja_JP.UTF-8 ;\
    localedef -c -f UTF-8 -i de_DE de_DE.UTF-8 ;\
    localedef -c -f UTF-8 -i af_ZA af_ZA.UTF-8

EXPOSE 80

# Clone ansible files (uncomment to enable)
RUN rm -rf /etc/ansible #redo
RUN rm -rf /tmp/status_page
RUN git clone https://stash.dev-charter.net/stash/scm/portals/status_page.git /tmp/status_page #redo
RUN cd /tmp/status_page && git checkout 0.8
RUN git clone https://github.com/gdraheim/docker-systemctl-replacement.git /tmp/status_page/docker/files/docker-systemctl-replacement
RUN cp /tmp/status_page/docker/files/docker-systemctl-replacement/files/docker/systemctl.py /usr/bin/systemctl
RUN mv /tmp/status_page/ansible /etc/ansible

# Install Ansible inventory file
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts
RUN echo -e '[frontend]\nlocalhost ansible_connection=docker' >> /etc/ansible/hosts

# Run ansible
RUN ansible-playbook -i "localhost," -c local /etc/ansible/plays/status_page.yml

# Some cleanup to make Cachet run
RUN chown -R apache:apache /var/www/Cachet/*

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/sbin/init"]
