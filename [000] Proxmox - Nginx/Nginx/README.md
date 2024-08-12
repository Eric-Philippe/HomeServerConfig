# Nginx

## Enabling Nginx

### Install Nginx

```bash
sudo apt install certbot python3-certbot-nginx
```

### Add domain

Create a file in `/etc/nginx/sites-available` with the following content:

```nginx
server {
    listen 80;
    server_name domain.com; # Change this to your domain

    location / {
        proxy_pass http://localhost:3000; # Change this to the port your app is running on
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Then create a symbolic link to the `sites-enabled` directory:

```bash
ln -s /etc/nginx/sites-available/domain.com /etc/nginx/sites-enabled/domain.com
```

### Enabling SSL

To enable SSL, you need to create a self-signed certificate:

```bash
sudo certbot --nginx -d domain.com
```

## Restart Nginx

```bash
sudo systemctl restart nginx
```
