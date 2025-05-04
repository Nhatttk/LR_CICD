#!/bin/bash

# Cập nhật hệ thống
sudo yum update -y || sudo apt update -y

# Cài đặt Docker
if command -v apt > /dev/null; then
  # Ubuntu
  sudo apt install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
else
  # Amazon Linux
  sudo yum install -y docker
  sudo service docker start
  sudo systemctl enable docker
fi

# Cài đặt Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Thêm user hiện tại vào nhóm docker
sudo usermod -aG docker $USER

echo "Cài đặt Docker và Docker Compose hoàn tất. Vui lòng đăng xuất và đăng nhập lại để áp dụng thay đổi nhóm docker." 

# Cài đặt Node.js và npm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18
npm install -g npm@latest

echo "Cài đặt Node.js và npm hoàn tất."