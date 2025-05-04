#!/bin/bash
set -e  # Dừng script nếu có lỗi

echo "===== BẮT ĐẦU CÀI ĐẶT MÔI TRƯỜNG EC2 ====="

# Kiểm tra quyền root hoặc sudo
if [ "$(id -u)" != "0" ] && ! sudo -v &>/dev/null; then
    echo "Lỗi: Script này cần quyền sudo để cài đặt các gói cần thiết."
    exit 1
fi

# Cập nhật hệ thống
echo "Đang cập nhật hệ thống..."
if command -v apt > /dev/null; then
    # Ubuntu
    sudo apt update -y || { echo "Lỗi khi cập nhật hệ thống"; exit 1; }
else
    # Amazon Linux
    sudo yum update -y || { echo "Lỗi khi cập nhật hệ thống"; exit 1; }
fi

# Cài đặt Docker
echo "Đang cài đặt Docker..."
if command -v apt > /dev/null; then
    # Ubuntu
    sudo apt install -y docker.io || { echo "Lỗi khi cài đặt Docker"; exit 1; }
    sudo systemctl enable docker || { echo "Lỗi khi kích hoạt Docker"; exit 1; }
    sudo systemctl start docker || { echo "Lỗi khi khởi động Docker"; exit 1; }
else
    # Amazon Linux
    sudo yum install -y docker || { echo "Lỗi khi cài đặt Docker"; exit 1; }
    sudo service docker start || { echo "Lỗi khi khởi động Docker"; exit 1; }
    sudo systemctl enable docker || { echo "Lỗi khi kích hoạt Docker"; exit 1; }
fi

# Cài đặt Docker Compose
echo "Đang cài đặt Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose || { echo "Lỗi khi tải Docker Compose"; exit 1; }
sudo chmod +x /usr/local/bin/docker-compose || { echo "Lỗi khi cấp quyền cho Docker Compose"; exit 1; }

# Thêm user hiện tại vào nhóm docker
sudo usermod -aG docker $USER || { echo "Lỗi khi thêm user vào nhóm docker"; exit 1; }

# Cài đặt Node.js và npm
echo "Đang cài đặt Node.js và npm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash || { echo "Lỗi khi cài đặt NVM"; exit 1; }
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Tải nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # Tải bash_completion
nvm install 18 || { echo "Lỗi khi cài đặt Node.js"; exit 1; }
nvm use 18 || { echo "Lỗi khi sử dụng Node.js"; exit 1; }
npm install -g npm@latest || { echo "Lỗi khi cập nhật npm"; exit 1; }

# Cấp quyền thực thi cho deploy_ec2.sh
if [ -f deploy_ec2.sh ]; then
    chmod +x deploy_ec2.sh || { echo "Lỗi khi cấp quyền thực thi cho deploy_ec2.sh"; exit 1; }
    echo "Đã cấp quyền thực thi cho deploy_ec2.sh"
fi

echo ""
echo "===== CÀI ĐẶT HOÀN TẤT ====="
echo ""
echo "QUAN TRỌNG: Bạn CẦN PHẢI đăng xuất và đăng nhập lại để áp dụng các thay đổi nhóm docker."
echo "Sau khi đăng nhập lại, chạy lệnh sau để triển khai ứng dụng:"
echo "  ./deploy_ec2.sh"
echo ""
echo "Nếu không muốn đăng xuất, bạn có thể chạy lệnh sau để cập nhật phiên hiện tại:"
echo "  exec su - $USER"
echo "Sau đó chạy lệnh triển khai."