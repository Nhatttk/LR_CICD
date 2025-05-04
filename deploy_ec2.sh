#!/bin/bash

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
docker-compose up -d

# Thiết lập Laravel trong container
echo "Thiết lập Laravel..."
docker-compose exec app composer install
docker-compose exec app npm install
docker-compose exec app php artisan key:generate
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan migrate --force

echo "Triển khai hoàn tất! Ứng dụng đang chạy tại:"
echo "- Backend: http://localhost:8000"
echo ""
echo "Lưu ý: Thay 'localhost' bằng địa chỉ IP công khai của EC2 khi truy cập từ xa" 

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