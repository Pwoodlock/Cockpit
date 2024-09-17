#!/bin/bash
# Description: This script installs Docker and Cockpit on supported Linux distributions.
# Usage: Run the script with sudo privileges: `sudo ./this_script.sh`
# Dependencies: curl, gpg, apt-get

# Section for your ASCII art at the beginning
clear
# ASCII Art
cat << "EOF"









     _________________________________________
     < Cockpit & Docker CE - Compose -v2+ 
        and plugins Auto-Installer           >



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
# Function to display messages in colors
display_message() {
    case $1 in
        "success")
            echo -e "\e[32m$2\e[0m" # Green for success messages
            ;;
        "error")
            echo -e "\e[31m$2\e[0m" # Red for error messages
            ;;
        "info")
            echo -e "\e[34m$2\e[0m" # Blue for informational messages
            ;;
    esac
}

# Function to handle errors
handle_error() {
    if [ $? -ne 0 ]; then
        display_message "error" "An error occurred: $1"
        exit 1
    fi
}

# Function to add Docker’s official GPG key
add_docker_gpg_key() {
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    handle_error "Failed to add Docker GPG key."
}

# Function to check and install a package if not already installed
ensure_package() {
    PACKAGE=$1
    if ! dpkg -s $PACKAGE &> /dev/null; then
        echo "Package $PACKAGE is not installed. Installing..."
        sudo apt-get install -y $PACKAGE
        handle_error "Failed to install $PACKAGE."
    else
        echo "Package $PACKAGE is already installed. Skipping..."
    fi
}

# Check and install necessary packages
ensure_package curl
ensure_package git
ensure_package ufw
ensure_package wget


# Function to install Docker
install_docker() {
    . /etc/os-release

    case $ID in
        "ubuntu"|"debian")
            display_message "info" "Installing Docker for $ID..."
            sudo apt-get update
            handle_error "Failed to update package lists."

            sudo apt-get install -y ca-certificates curl gnupg lsb-release
            handle_error "Failed to install prerequisites."

            add_docker_gpg_key

            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$ID \
              $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io
            handle_error "Failed to install Docker."

            # Install Docker Compose
            sudo curl -L "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            handle_error "Failed to install Docker Compose."

            # Add user to Docker group
            read -p "Enter the username to be added to the Docker group: " username
            sudo usermod -aG docker $username
            handle_error "Failed to add user to Docker group."

            sudo systemctl daemon-reload
            sudo systemctl restart docker
            handle_error "Failed to restart Docker service."

            display_message "success" "Docker and Docker Compose installed successfully."
            ;;
        *)
            display_message "error" "Your distribution ($ID) is not supported by this script."
            ;;
    esac
}

# Function to install Cockpit
install_cockpit() {
    display_message "info" "Installing Cockpit..."

    . /etc/os-release

    if [[ "$ID" == "debian" ]]; then
        display_message "info" "Installing Cockpit for Debian from backports..."
        echo "deb http://deb.debian.org/debian ${VERSION_CODENAME}-backports main" | sudo tee /etc/apt/sources.list.d/backports.list
        sudo apt update
        sudo apt install -y -t ${VERSION_CODENAME}-backports cockpit
    elif [[ "$ID" == "ubuntu" ]]; then
        display_message "info" "Installing Cockpit for Ubuntu..."
        sudo apt install -y cockpit
        . /etc/os-release
        apt update
        apt install cockpit-navigator cockpit-sosreport cockpit-sensors cockpit-zfs cockpit-pcp -y
        apt upgrade -t ${VERSION_CODENAME}-backports cockpit -y
    else
        display_message "error" "Cockpit installation for $ID is not supported in this script."
    fi

    display_message "success" "Cockpit installed successfully."
}

# Main script execution
clear
install_docker
install_cockpit

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
# ASCII Art
cat << "EOF"




                            Thank's  P U $ $ for all your help!





EOF
sleep 4

echo " Installation is now complete. Your Cockpit server is ready to use at the following URL:http://<IP>:3003 "
echo ""
echo ""
echo "                    Docker CE and Docker Compose installed successfully."

