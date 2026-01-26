#!/bin/bash
set -e

# Log everything to file and also print to terminal
LOG_FILE="/home/ec2-user/all_install_log.txt"
exec > >(tee -i $LOG_FILE)
exec 2>&1

echo "=============================================="
echo "STARTING ALL-IN-ONE INSTALL SCRIPT"
echo "Logging to $LOG_FILE"
echo "=============================================="

# ------------------------------
# Update system
# ------------------------------
echo "=== Updating system ==="
sudo yum update -y

# ------------------------------
# Install Java 17 (Amazon Corretto)
# ------------------------------
echo "=== Installing Java 17 (Amazon Corretto) ==="
sudo yum install -y java-17-amazon-corretto-headless

# Find actual Java binary path
JAVA_PATH=$(sudo find /usr/lib/jvm/ -name java | grep java-17-amazon-corretto | head -n 1)
echo "Detected Java path: $JAVA_PATH"

# Register Java with alternatives
sudo alternatives --install /usr/bin/java java $JAVA_PATH 1
sudo alternatives --set java $JAVA_PATH

# Verify Java installation
echo "=== Verify Java ==="
java -version
readlink -f $(which java)

# ------------------------------
# Jenkins Installation
# ------------------------------
echo "=== Adding Jenkins repository ==="
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/rpm/jenkins.io-2023.key

echo "=== Installing Jenkins ==="
sudo yum install -y jenkins

# Fix permissions for Jenkins directories
sudo chown -R jenkins:jenkins /var/lib/jenkins /var/log/jenkins /var/cache/jenkins

# Reload systemd and start Jenkins
echo "=== Reloading systemd and starting Jenkins ==="
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Jenkins status
echo "=== Jenkins status ==="
sudo systemctl status jenkins --no-pager

# ------------------------------
# Git Installation
# ------------------------------
echo "=== Installing Git ==="
sudo yum install -y git
git --version

# ------------------------------
# Terraform Installation
# ------------------------------
echo "=== Installing Terraform ==="
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform
terraform -version

# ------------------------------
# kubectl Installation
# ------------------------------
echo "=== Installing kubectl ==="
KUBE_VERSION="v1.23.6"
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl
kubectl version --client --short

# ------------------------------
# Final info
# ------------------------------
echo "=============================================="
echo "ALL TOOLS INSTALLED SUCCESSFULLY"
echo "Jenkins: http://<EC2-PUBLIC-IP>:8080"
echo "Initial Jenkins admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "Log file: $LOG_FILE"
echo "=============================================="
