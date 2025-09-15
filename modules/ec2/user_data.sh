#!/bin/bash
apt update -y
apt upgrade -y

# Install Docker
apt install -y ca-certificates curl gnupg lsb-release

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable & start Docker
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create required directories
mkdir -p /var/www/pavement/nginx/sites /var/www/pavement/nginx/logs /wiki/mysql-data
chown -R 999:999 /wiki/mysql-data

# Create docker-compose directory
mkdir -p /home/ubuntu/wiki
cd /home/ubuntu/wiki

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: "3.8"

services:
  wiki-api:
    image: docker-registry.appscyclone.com/g2x-wiki-api:master-latest
    container_name: wiki_api
    restart: always
    networks:
      - pavement

  wiki-fe:
    image: docker-registry.appscyclone.com/g2x-wiki-fe:master-latest
    container_name: wiki_fe
    restart: always
    networks:
      - pavement

  redis:
    image: redis:6.2
    container_name: redis
    restart: always
    command: redis-server --requirepass secret_redis
    volumes:
      - redis_data:/data
    networks:
      - pavement

  mysql:
    image: mysql:8.0
    container_name: mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: Secure@Pavement25
      MYSQL_DATABASE: g2x_wiki
      MYSQL_USER: wiki_admin
      MYSQL_PASSWORD: letmein12345
    volumes:
      - /wiki/mysql-data:/var/lib/mysql
    ports:
      - "3306:3306"
    networks:
      - pavement

  nginx:
    image: nginx:latest
    container_name: nginx
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/www/pavement/nginx/sites:/etc/nginx/conf.d
      - /var/www/pavement/nginx/logs:/var/log/nginx
    depends_on:
      - wiki-fe
      - wiki-api
    networks:
      - pavement

volumes:
  redis_data:

networks:
  pavement:
    driver: bridge
EOF

# Create nginx directories
mkdir -p /var/www/pavement/nginx/sites /var/www/pavement/nginx/logs

# Create nginx config files
cat > /var/www/pavement/nginx/sites/g2x-wiki.conf << 'EOF'
# Redirect HTTP sang HTTPS
server {
    listen 80;
    server_name pavement-beta.appscyclone.com www.pavement-beta.appscyclone.com;

    return 301 https://$host$request_uri;
}

# HTTPS server
server {
    listen 443;
    server_name pavement-beta.appscyclone.com www.pavement-beta.appscyclone.com;

    access_log /var/log/nginx/g2x-wiki-access.log;
    error_log  /var/log/nginx/g2x-wiki-error.log;
    client_max_body_size 10M;

    location / {
        proxy_pass http://wiki_fe:3000;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

cat > /var/www/pavement/nginx/sites/g2x-wiki-api.conf << 'EOF'
# Redirect HTTP sang HTTPS
server {
    listen 80;
    server_name pavement-beta-api.appscyclone.com www.pavement-beta-api.appscyclone.com;
    return 301 https://$host$request_uri;
}

# HTTPS server
server {
    listen 443;
    server_name pavement-beta-api.appscyclone.com www.pavement-beta-api.appscyclone.com;

    access_log /var/log/nginx/g2x-wiki-api-access.log;
    error_log  /var/log/nginx/g2x-wiki-api-error.log;
    client_max_body_size 10M;

    location / {
        proxy_pass http://wiki_api:4000;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Start services
docker compose up -d

# Install AWS CLI
apt install -y awscli