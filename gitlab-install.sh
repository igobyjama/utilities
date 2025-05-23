# install dependencies
sudo dnf install -y curl policycoreutils postfix openssh-server perl

# Enable OpenSSH server daemon if not enabled: sudo systemctl status sshd
sudo systemctl enable sshd
sudo systemctl start sshd

# Check if opening the firewall is needed with: sudo systemctl status firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo systemctl reload firewalld

sudo systemctl enable postfix
sudo systemctl start postfix

curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash

sudo EXTERNAL_URL="https://gitlab.example.com" dnf install -y gitlab-ee
# List available versions: sudo dnf --showduplicates list
# Specify version: sudo dnf install gitlab-ee-16.1.4-ee.0.el7

