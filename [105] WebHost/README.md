# WebHost

## Allow distant monitoring

```bash
sudo nano /lib/systemd/system/docker.service
```

Edit the following line:

```bash
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 --containerd=/run/containerd/containerd.sock
```
