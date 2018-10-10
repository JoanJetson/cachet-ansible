FROM centos/systemd

RUN yum -y upgrade
RUN yum -y install gcc sudo epel-release libffi-devel \
    git python-devel openssl-devel python-setuptools  \
    https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
RUN yum clean all
RUN easy_install pip
RUN pip install ansible

# Set root password
RUN echo "root:Docker!" | chpasswd

# Clone ansible files (uncomment to enable)
RUN rm -rf /etc/ansible #redo
RUN rm -rf /tmp/status_page
RUN git clone https://stash.dev-charter.net/stash/scm/portals/status_page.git /tmp/status_page #redo
RUN cd /tmp/status_page && git checkout 0.8
RUN git clone https://github.com/gdraheim/docker-systemctl-replacement.git /tmp/status_page/docker/files/docker-systemctl-replacement
RUN cp /tmp/status_page/docker/files/docker-systemctl-replacement/files/docker/systemctl.py /usr/bin/systemctl
RUN mv /tmp/status_page/ansible /etc/ansible

# Replace Systemd. NOTE: ! this needs to have a clone option
COPY docker/files/docker-systemctl-replacement/files/docker/systemctl.py /usr/bin/systemctl

# Install Ansible inventory file
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts
RUN echo -e '[frontend]\nlocalhost ansible_connection=docker' >> /etc/ansible/hosts

# Note: extra var will too have the hostname for cachet set
RUN ansible-playbook \
    -i "localhost,"  \
    --extra-vars "cachet_hostname=172.17.0.2" \
    -c local /etc/ansible/plays/cachet_monitor.yml

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/sbin/init"]
