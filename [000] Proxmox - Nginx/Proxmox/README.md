# Proxmox

## Change Proxmox apt sources

Change `/etc/apt/sources.list` to:

```txt
deb http://ftp.fr.debian.org/debian bookworm main contrib

deb http://ftp.fr.debian.org/debian bookworm-updates main contrib

# security updates
deb http://security.debian.org bookworm-security main contrib

# deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
```

Change `/etc/apt/sources.list.d/pve-enterprise.list` to:

```txt
# deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise

deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
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

## Install Node-Exporter

```bash
docker run -d \
  --name=node-exporter \
  -p 9100:9100 \
  --restart=always \
  prom/node-exporter \
  /bin/node_exporter
```

## Mount NAS SMB share

Add to `/etc/fstab`:

```txt
# Mount CIFS share on demand with rwx permissions for use in LXCs (manually added)
//192.168.1.141/mediaserver /mnt/mediaserver cifs _netdev,x-systemd.automount,noatime,uid=100000,gid=110000,dir_mode=0770,file_mode=0770,user=user,pass=supersecurepassword 0 0
//192.168.1.141/nextcloud /mnt/nextcloud cifs _netdev,x-systemd.automount,noatime,uid=100000,gid=110000,dir_mode=0770,file_mode=0770,user=user,pass=supersecurepassword 0 0
```

Then update the fstab:

```bash
sudo mount -a
```

Then mount it to the Jellyfin container:

```bash
{ echo 'mp0: /mnt/mediaserver/,mp=/mnt/mediaserver' ; } | tee -a /etc/pve/lxc/103.conf
```

## Setup powersave governor

```bash
crontab -e

# Add the following line:
@reboot (sleep 60 && echo "powersave" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor)
```

## Generate monitoring user with token and monitoring permission

> <https://www.youtube.com/watch?v=PtsdThgnZqs>

## Enable all the powersave features

```bash
sudo apt-get install powertop
sudo powertop --auto-tune
```

## Disable disable pve-ha-crm and pve-ha-lrm

```bash
systemctl stop pve-ha-crm
systemctl stop pve-ha-lrm
systemctl disable pve-ha-crm
systemctl disable pve-ha-lrm
```
