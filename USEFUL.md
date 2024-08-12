# Useful

## Table of Contents

## Create new sudoer user

```bash
# Create a new user:
sudo adduser eric

# Add the user to the sudo group:
sudo usermod -aG sudo eric
```

## Install Docker

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

```bash
# Install Docker:
 sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

```bash
# Add user to the docker group:
sudo usermod -aG docker eric
```

## Setup and deploy ssh key to remote server

```bash
# Generate a new SSH key on your local machine:
ssh-keygen -t rsa -b 4096 -C "ericphlpp@gmail.com"

# Copy the SSH key to the remote server:
ssh-copy-id -i ~/.ssh/id_rsa.pub user@hostname
```
