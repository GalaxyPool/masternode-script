#!/bin/bash
bla=$(tput setaf 0)
red=$(tput setaf 1)
gre=$(tput setaf 2)
yel=$(tput setaf 3)
blu=$(tput setaf 4)
end=$(tput sgr0)

function display_banner(){
echo -n $gre
cat << _banner
  ╔═══════════════════════════════════════════════════════════════════╗
  ║   __  __    _    ____ _____ _____ ____  _   _  ___  ____  _____   ║
  ║  |  \/  |  / \  / ___|_   _| ____|  _ \| \ | |/ _ \|  _ \| ____|  ║
  ║  | |\/| | / _ \ \___ \ | | |  _| | |_) |  \| | | | | | | |  _|    ║
  ║  | |  | |/ ___ \ ___) || | | |___|  _ <| |\  | |_| | |_| | |___   ║
  ║  |_|  |_/_/   \_\____/ |_| |_____|_| \_\_| \_|\___/|____/|_____|  ║
  ║                                                                   ║
  ║    _____  _______________   __   __                               ║
  ║   /  _/ |/ / __/_  __/ _ | / /  / /                               ║
  ║  _/ //    /\ \  / / / __ |/ /__/ /__       Script by Duy Nguyen   ║
  ║ /___/_/|_/___/ /_/ /_/ |_/____/____/       https://fb.com/duyk16  ║
  ║                                                                   ║
  ╚═══════════════════════════════════════════════════════════════════╝
           1) INSTALL MASTERNODE
           2) MASTERNODE INFORMATIONS
           3) MASTERNODE STATUS
           4) REMOVE OLD FILE
           5) EXIT
_banner
echo -n $end
}

# check ubuntu version
function checks_ubuntu() {
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${red}You are not running Ubuntu 16.04. Installation is cancelled.${end}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${red}Script must be run as root.${end}"
   exit 1
fi
}

function choice() {
  read -r -p "  ${yel}Enter your choice [1-5]: $end" choice
  if [ $choice = 1 ];
  then
    download_file
    install_firewall
    install_mn
    echo "${yel}Getting informations ..."
    sleep 10
    footer
  elif [ $choice = 2 ];
  then
    footer
  elif [ $choice = 3 ];
  then
	systemctl status masternode.service
	read -r -p "  ${yel}Back to menu [y/n]: $end" back
    case "$back" in
         [yY][eE][sS]|[yY])
          menu
             ;;
         *)
             exit
             ;;
    esac
  elif [ $choice = 4 ];
  then
    echo "  ${yel}Removing old file ..."
    systemctl stop masternode.service
    rm -rf /root/geth-linux-amd64.zip
    rm -rf /root/geth-linux-amd64/
    rm -rf /usr/sbin/geth
    rm -rf /root/tools.sh
    rm -rf /tmp/masternode.service
    rm -rf /root/.roller/
    rm -rf /etc/systemd/system/masternode.service
    echo "  ${yel}Remove complete"
	read -r -p "  Back to menu [y/n]: $end" back
    case "$back" in
         [yY][eE][sS]|[yY])
          menu
             ;;
         *)
             exit
             ;;
    esac
  elif [ $choice = 5 ];
  then
	exit
  else
    echo " ${yel} You must choice from 1-4. ${end}"
  fi
}

# FOOTER
footer () {
clear
echo -n $gre && echo
cat << _success
  --------------------- SUCCESS CONFIGURATION -----------------------
_success
echo
echo "  ${red}Masternode IP:${end} $(curl -s4 api.ipify.org)"
echo "  ${red}Masternode PORT:${end} $(journalctl -u masternode.service | grep 'HTTP endpoint opened' | awk '{print $11}' | awk '{print $1}' | grep -o -P '(?<=http://0.0.0.0:).*' | tail -1)"
echo "  ${red}Masternode ID:${end} $(journalctl -u masternode.service | grep 'UDP listener up' | awk '{print $11}' | grep -o -P '(?<=node://).*(?=@)' | tail -1)"
echo -n $yel && echo
cat << _information
     /- This script only work with Ubuntu 16.04 x64
     /- Script made by Duy Nguyen
     /- Contact: fb.com/duyk16
     /- Donations:
           * ETH/ETC: 0xBEB1B4ae55A1C0873c60947724Ae8b58B7Def191
           * ROLLER: 0x0eead76e3edd5a09879a42aeb00eacbb77d641b4
_information
echo -n $gre && echo
echo "  -----------------------------------------------------------------"
echo -n $end && echo
read -r -p " ${yel}Back to menu [y/n]: $end" back
case "$back" in
     [yY][eE][sS]|[yY])
      menu
         ;;
     *)
         exit
         ;;
esac
}

function download_file() {
    read -r -p " ${yel}Do you want to download needed file (no if you did it before)? [y/n] ${end}" confirm
    case "$confirm" in
        [yY][eE][sS]|[yY])
            wget https://github.com/roller-project/roller/releases/download/1.2.1/geth-linux-amd64.zip
            wget https://raw.githubusercontent.com/roller-project/masternode/master/tools.sh
            ;;
    esac
}

function install_firewall() {
  echo -e "Installing and setting up firewall to allow ingress on port ${yel}8545${end}"
  apt-get install -y ufw
  ufw allow 8545 comment "ROLLER MN port" >/dev/null
  ufw allow 30301 >/dev/null
  ufw allow ssh comment "SSH" >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
}

function install_mn() {
cd
apt-get -y install unzip wget git curl
unzip geth-linux-amd64.zip
mv ~/geth-linux-amd64/geth-linux-amd64 /usr/sbin/geth
cat > /tmp/masternode.service << EOL
[Unit]
Description=$COIN_NAME Client -- masternode service
After=network.target
[Service]
Type=simple
Restart=always
RestartSec=30s
ExecStart=/usr/sbin/geth --masternode --rpcport 8545 --rpcvhosts *
[Install]
WantedBy=default.target
EOL

sudo \mv /tmp/masternode.service /etc/systemd/system
sudo systemctl enable masternode && systemctl start masternode
}

function menu() {
  clear
  display_banner
  checks_ubuntu
  choice
}

menu
