# Tailscale

## Install from Proxmox Script

```bash
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/add-tailscale-lxc.sh)"
```

## Advertise a device as an exit node

```bash
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
```

## Setup as a subnet router

```bash
sudo tailscale up --advertise-routes=192.168.1.0/24 --advertise-exit-node
```
