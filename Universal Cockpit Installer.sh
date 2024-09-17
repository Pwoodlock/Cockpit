#!/bin/bash
# Universal Cockpit Installer and create sudo user with ssh key
clear
# ASCII Art
cat << "EOF"









     _________________________________________
     < Cockpit and plugins Auto-Installer >



######  Pu$$ The Rockfield Mascot is here to help!  #######
                                _
                                | \
                                 | |
                                  | |
            |\                    | |
            /, ~\                 / /
           < X     `-.....-------./ /
            ~-. ~  ~              x|
                \   P U $ $  /    |
                \  /_     ___\   /
                | /\ ~~~~~   \ |
                | | \        || |
                | |\ \       || )
                (_/ (_/      ((_/
......................................................

EOF
sleep 10
. /etc/os-release

if [[ "$ID" == "debian" ]]; then
    echo "Detected Debian. Installing Cockpit for Debian."
    echo "deb http://deb.debian.org/debian ${VERSION_CODENAME}-backports main" > \
    /etc/apt/sources.list.d/backports.list
    apt update
    apt upgrade -t ${VERSION_CODENAME}-backports cockpit -y
elif [[ "$ID" == "ubuntu" ]]; then
    echo "Detected Ubuntu. Installing Cockpit for Ubuntu."
    sudo apt install -t ${VERSION_CODENAME}-backports cockpit
    . /etc/os-release
    apt update
    apt install cockpit-navigator cockpit-sosreport cockpit-sensors cockpit-zfs cockpit-pcp -y
    apt upgrade -t ${VERSION_CODENAME}-backports cockpit -y
    

else
    echo "Your distribution ($ID) is not supported by this script."
    exit 1
fi

apt install -y curl git ufw wget
wget -qO - https://repo.45drives.com/key/gpg.asc | sudo gpg --dearmor -o /usr/share/keyrings/45drives-archive-keyring.gpg
curl -sSL https://repo.45drives.com/lists/45drives.sources -o /etc/apt/sources.list.d/45drives.sources
apt update
. /etc/os-release
sudo apt install -y cockpit-navigator && cockpit-sosreport && cockpit-sensors && cockpit-zfs && cockpit-pcp
bash -c 'echo -e "[keyfile]\nunmanaged-devices=none" > /etc/NetworkManager/conf.d/10-globally-managed-devices.conf' && sudo systemctl restart NetworkManager -y
nmcli con add type dummy con-name fake ifname fake0 ip4 1.2.3.4/24 gw4 1.2.3.1

mkdir -p /etc/systemd/system/cockpit.socket.d
touch /etc/systemd/system/cockpit.socket.d/listen.conf
echo "[Socket]" | sudo tee /etc/systemd/system/cockpit.socket.d/listen.conf
echo "ListenStream=" | sudo tee -a /etc/systemd/system/cockpit.socket.d/listen.conf
echo "ListenStream=3003" | sudo tee -a /etc/systemd/system/cockpit.socket.d/listen.conf
systemctl restart cockpit.socket

systemctl daemon-reload
. /etc/os-release
apt upgrade -t ${VERSION_CODENAME}-backports cockpit -y
apt upgrade python3 -y

clear
# ASCII Art
cat << "EOF"






              _
             | \
              | |
              | |
              | |
              / /
.....-------./ /
              x| 
P U $ $  /    |
_     ___\   /
 ~~~~~   \ |
 \        || |
|\ \       || )
 (_/      ((_/
 -------------------------------------------------

EOF
sleep 3
clear
# ASCII Art
cat << "EOF"




                            Thank's  P U $ $ for all your help!





EOF
sleep 4

echo " Installation is now complete. Your Cockpit server is ready to use at the following URL:http://<IP>:3003 "
echo ""
echo ""
echo "                    Docker CE and Docker Compose installed successfully."
