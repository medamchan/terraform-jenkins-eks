#!/bin/bash
set -euo pipefail

# ------------------------------
# Force root
# ------------------------------
if [ "$EUID" -ne 0 ]; then
  exec sudo -E bash "$0" "$@"
fi

# ------------------------------
# Logging (safe for AL2)
# ------------------------------
LOG_FILE="/home/ec2-user/bootstrap.log"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo "====================================="
echo " EC2 BOOTSTRAP STARTED (AL2)"
echo "====================================="

sleep 10

# ------------------------------
# System prep (DO NOT FAIL)
# ------------------------------
yum clean all || true
yum makecache || true
yum update -y || true

# ------------------------------
# Install Git (FIRST)
# ------------------------------
echo "Installing Git..."
yum install -y git
git --version

# ------------------------------
# Install Java 17
# ------------------------------
echo "Installing Java 17..."
yum install -y java-17-amazon-corretto-headless
java -version

# ------------------------------
# Install Jenkins
# ------------------------------
echo "Installing Jenkins..."
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io-2023.key

yum install -y jenkins
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

# ------------------------------
# Install Terraform (HashiCorp repo)
# ------------------------------
echo "Installing Terraform..."
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum install -y terraform
terraform -version

# ------------------------------
# Install kubectl
# ------------------------------
echo "Installing kubectl..."
KUBE_VERSION="v1.23.6"
curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl
kubectl version --client

# ------------------------------
# Jenkins permissions
# ------------------------------
chown -R jenkins:jenkins /var/lib/jenkins || true

# ------------------------------
# Done
# ------------------------------
echo "====================================="
echo " BOOTSTRAP COMPLETED SUCCESSFULLY"
echo " Jenkins URL: http://<EC2-PUBLIC-IP>:8080"
echo " Jenkins admin password:"
cat /var/lib/jenkins/secrets/initialAdminPassword
echo " Log file: $LOG_FILE"
echo "====================================="
