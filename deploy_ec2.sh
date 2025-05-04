#!/bin/bash
set -e  # Dừng script nếu có lỗi

# Kiểm tra Docker đã chạy chưa
if ! docker info > /dev/null 2>&1; then
    echo "Lỗi: Docker không chạy. Vui lòng khởi động Docker và thử lại."
    echo "Sử dụng: sudo systemctl start docker (hoặc sudo service docker start)"
    exit 1
fi

# Kiểm tra docker-compose đã cài đặt chưa
if ! command -v docker-compose > /dev/null; then
    echo "Lỗi: Docker Compose chưa được cài đặt hoặc không trong PATH."
    echo "Vui lòng chạy ec2_setup.sh trước, sau đó đăng xuất và đăng nhập lại."
    exit 1
fi

# Đảm bảo ứng dụng Laravel đã cài đặt và cấu hình
echo "Chuẩn bị ứng dụng Laravel..."

# Copy .env.example thành .env nếu chưa có file .env
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Đã tạo file .env từ .env.example"
fi

# Khởi chạy docker compose
echo "Khởi chạy các container..."
docker-compose down
docker-compose up -d --build

# Đợi để đảm bảo containers đã chạy
echo "Đợi các container khởi động..."
sleep 10

# Thiết lập Laravel trong container
echo "Thiết lập Laravel..."
if ! docker-compose exec app composer install; then
    echo "Lỗi khi cài đặt composer dependencies"
    exit 1
fi

# npm install đã được xử lý trong node container, không cần chạy ở đây
# Chạy các lệnh Laravel cần thiết
if ! docker-compose exec app php artisan key:generate; then
    echo "Lỗi khi tạo key ứng dụng"
    exit 1
fi

if ! docker-compose exec app php artisan config:cache; then
    echo "Lỗi khi cache config"
    exit 1
fi

if ! docker-compose exec app php artisan migrate --force; then
    echo "Lỗi khi migrate database"
    exit 1
fi

# Lấy địa chỉ IP công khai của EC2
EC2_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "localhost")

echo "Triển khai hoàn tất! Ứng dụng đang chạy tại:"
echo "- Backend: http://$EC2_IP:8000"
echo ""
echo "Lưu ý: Đảm bảo security group của EC2 đã mở cổng 8000 và 3306 nếu cần thiết" 

# #!/bin/bash
# set -e
# echo "Deploy production..."
# docker-compose down
# docker-compose up -d --build
# docker-compose exec app php artisan migrate --force

# echo "Triển khai hoàn tất! Ứng dụng đang chạy tại:"
# echo "- Backend: http://localhost:8000"
# echo ""
# echo "Lưu ý: Thay 'localhost' bằng địa chỉ IP công khai của EC2 khi truy cập từ xa" 