---
Cockpit: Installation and Setup
aliases:
  - Administration
  - Linux
tags: cockpit, administration
---

> [!NOTE]
>These commands require a POSIX compatible shell like `bash`. For other shells like `fish`, temporarily run `bash -i`.

Cockpit is available in Ubuntu, with [updated versions in official backports for LTS releases](https://help.ubuntu.com/community/UbuntuBackports).

We recommend installing or updating the latest version from backports. This repository is enabled by default, but if you customized apt sources you might need to [enable them manually](https://help.ubuntu.com/community/UbuntuBackports#Enabling_Backports).





Cockpit is available in Ubuntu, with [updated versions in official backports for LTS releases](https://help.ubuntu.com/community/UbuntuBackports).

We recommend installing or updating the latest version from backports. This repository is enabled by default, but if you customized apt sources you might need to [enable them manually](https://help.ubuntu.com/community/UbuntuBackports#Enabling_Backports).


> [!NOTE]
> 
>***INSTALLATION***
> 
> Ubuntu / Debian have a weird issues that have been notified for a while now regarding their package.manager in NetworkManager:  You need to apply this this command to and either reboot the machine or restart the NetworkManger daemon. I gather it will depend on your situation, but first check to see if you have update issues in Cockpit's Dashboard under "Software Updates"

> Reference Link
> https://github.com/cockpit-project/cockpit/issues/16963



Installation Instructions below for Ubuntu


```bash
. /etc/os-release
sudo apt install -t ${VERSION_CODENAME}-backports cockpit
```

When updating Cockpit-related packages and any dependencies, make sure to use `-t ...-backports` as above, so backports are included.

***Update Instructions:****

```bash
. /etc/os-release
sudo apt upgrade -t ${VERSION_CODENAME}-backports cockpit
```





### Debian

These commands require a POSIX compatible shell like `bash`. For other shells like `fish`, temporarily run `bash -i`.

Cockpit is available in Debian since version 10 (Buster).

1. To get the latest version, we recommend to enable the [backports repository](https://backports.debian.org/) (as root):
    
    ```
    . /etc/os-release
    echo "deb http://deb.debian.org/debian ${VERSION_CODENAME}-backports main" > \
        /etc/apt/sources.list.d/backports.list
    apt update
    ```
      
```
 apt install -t ${VERSION_CODENAME}-backports cockpit
```

When updating Cockpit-related packages and any dependencies, make sure to use `-t ...-backports` as above, so backports are included.






***First run this:***

```bash
nmcli con add type dummy con-name fake ifname fake0 ip4 1.2.3.4/24 gw4 1.2.3.1
```

***Then this:***

```bash
sudo bash -c 'echo -e "[keyfile]\nunmanaged-devices=none" > /etc/NetworkManager/conf.d/10-globally-managed-devices.conf' && sudo systemctl restart NetworkManager
```



***CHANGING THE DEFAULT PORT OF COCKPIT***


> [!NOTE]
> If you're running services that explicitly need the port of 9090 for outside comms etc, you need to change the port of cockpit.  We can change the port to anything we want as our service for cockpit is dark! with OpenZiti.  So let's begin.


```bash 
mkdir -p /etc/systemd/system/cockpit.socket.d
touch /etc/systemd/system/cockpit.socket.d/listen.conf
echo "[Socket]" | sudo tee /etc/systemd/system/cockpit.socket.d/listen.conf
echo "ListenStream=" | sudo tee -a /etc/systemd/system/cockpit.socket.d/listen.conf
echo "ListenStream=3003" | sudo tee -a /etc/systemd/system/cockpit.socket.d/listen.conf
systemctl restart cockpit.socket

```

