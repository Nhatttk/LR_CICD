FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Copy composer from official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy the rest of the application code
COPY . .

# Install PHP dependencies (optimized, no-dev for production)
RUN composer install --no-interaction --no-dev --optimize-autoloader

# Optional: Copy custom php.ini if needed
# COPY ./docker/php/php.ini /usr/local/etc/php/conf.d/

# Set correct permissions
RUN chown -R www-data:www-data /var/www

# Switch to non-root user
USER www-data

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start PHP-FPM server
CMD ["php-fpm"]
