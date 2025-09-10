# Dockerfile for the 'web' service with integrated CLI tools
# Base image: PHP 8.4 with Apache
FROM php:8.4-apache

# Install mongodb extension via pecl
RUN pecl install mongodb && docker-php-ext-enable mongodb

# 1. System Setup & Dependencies
# Install required system libraries for PHP extensions and utilities.
RUN apt-get update && apt-get install -y \
    openssh-server \
    net-tools \
    snmp \
    libssl-dev \
    libsnmp-dev \
    libpq-dev \
    libzip-dev \
    zip \
    curl \
    git \
    # CLI tools
    htop \
    iftop \
    nano \
    iputils-ping \
    telnet \
    openssl \
    # Dependency for mongodb pecl extension
    pkg-config \
    # For setting the locale
    locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Configure Locale
# Generate both en_US.UTF-8 and en_GB.UTF-8 locales to prevent warnings.
RUN sed -i -e '/en_US.UTF-8/s/^# //g' -e '/en_GB.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV LC_TIME en_GB.UTF-8

# 3. PHP Extension Installation
# Install the requested PHP extensions.
RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql pcntl snmp zip

# 4. Apache Configuration
# Enable necessary Apache modules for SSL and URL rewriting.
RUN a2enmod ssl rewrite

# Copy the custom SSL virtual host configuration.
# COPY apache/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
RUN a2ensite default-ssl

# 5. Install Composer (Globally)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 6. Set Timezone
ENV TZ=Asia/Bangkok
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 7. Set Command-Line Aliases
# Add custom aliases for the root user.
RUN echo "# custom alias\nalias ll='ls -alhF'" >> /root/.bashrc && \
    echo "alias lll='ls -alhF --time-style=long-iso'" >> /root/.bashrc && \
    echo "# custom alias\nalias ll='ls -alhF'" >> /etc/skel/.bashrc && \
    echo "alias lll='ls -alhF --time-style=long-iso'" >> /etc/skel/.bashrc  && \
    echo "# cd default path\ncd /var/www/html" >> /etc/skel/.bashrc 

RUN useradd -u 2000 -m -s /bin/bash -g www-data -G sudo codeserver && \
    # for disable root login via ssh service
    echo "PermitRootLogin no" > /etc/ssh/sshd_config.d/disable_root_login.conf

# 8. Add and configure the entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# The base image's CMD is ["apache2-foreground"], which will be executed by the entrypoint.
# CMD ["apache2-foreground"]

# 9. Set Working Directory
WORKDIR /var/www/html
