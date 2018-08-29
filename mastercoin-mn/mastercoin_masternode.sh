#!/bin/bash
bla=$(tput setaf 0)
red=$(tput setaf 1)
gre=$(tput setaf 2)
yel=$(tput setaf 3)
blu=$(tput setaf 4)
end=$(tput sgr0)

CONF_DIR=~/.MasterCoin/
CONF_FILE=MasterCoin.conf
COIN_NAME=MasterCoin
NODEIP=$(curl -s4 api.ipify.org)
PORT=16000


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
  ║             __  ___  _____                                        ║
  ║            /  |/  / / ___/                                        ║
  ║           / /|_/ / / /_                   Script by Duy Nguyen    ║
  ║          /_/  /_/  \___/                  https://fb.com/duyk16   ║
  ║                                                                   ║
  ╚═══════════════════════════════════════════════════════════════════╝
_banner
	echo -n $end
}

# CHECK UBUNTU VERSION
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
	echo -n $gre
	cat << _choice
		1) INSTALL MASTERNODE
		2) MASTERNODE INFORMATIONS
		3) MASTERNODE STATUS
		4) RESTART SERVICE
		5) REINSTALL PRIVATEKEY
		6) REMOVE OLD FILE
		7) EXIT
_choice
	echo -n $end  
	read -r -p "  ${yel}Enter your choice [1-7]: $end" choice
	if [ $choice = 1 ]; then
		${COIN_NAME}d stop
		remove_file
		download_file
		install_system
		install_firewall
		install_mn
		echo "${yel}Getting informations ..."
		sleep 5
		footer
	elif [ $choice = 2 ]; then
		footer
	elif [ $choice = 3 ]; then
		${COIN_NAME}d masternode status
		echo -n $yel
		cat << _status
	#0 = Masternode not processed / initial state 
	#1 = Masternode capable
	#2 = Masternode not capable
	#3 = Masternode stoped
	#4 = Masternode input too new
	#6 = Masternode port not open
	#7 = Masternode port open
	#8 = Masternode sync in process 
	#9 = Masternode Remotely enabled
_status
		read -r -p "  ${yel}Back to menu [y/n]: $end" back
		case "$back" in
         [yY][eE][sS]|[yY])
          menu
             ;;
         *)
             exit
             ;;
		esac
	elif [ $choice = 4 ]; then
		${COIN_NAME}d stop
		sleep 2
		${COIN_NAME}d
		echo "  ${end}Restart done."
		read -r -p "  ${yel}Back to menu [y/n]: $end" back
		case "$back" in
         [yY][eE][sS]|[yY])
          menu
             ;;
         *)
             exit
             ;;
		esac
	elif [ $choice = 5 ]; then
		cd
		${CONF_DIR}d stop
		sleep 2
		rm -rf $CONF_DIR/$CONF_FILE
		echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> $CONF_DIR/$CONF_FILE
		echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> $CONF_DIR/$CONF_FILE
		echo "listen=1" >> $CONF_DIR/$CONF_FILE
		echo "server=1" >> $CONF_DIR/$CONF_FILE
		echo "daemon=1" >> $CONF_DIR/$CONF_FILE
		echo "logtimestamps=1" >> $CONF_DIR/$CONF_FILE
		echo "maxconnections=64" >> $CONF_DIR/$CONF_FILE
		echo "masternode=1" >> $CONF_DIR/$CONF_FILE
		echo "" >> $CONF_DIR/$CONF_FILE
		echo "port=$PORT" >> $CONF_DIR/$CONF_FILE
		echo "masternodeaddress=$NODEIP:$PORT" >> $CONF_DIR/$CONF_FILE
		echo "masternodeprivkey=$PRIVATEKEY" >> $CONF_DIR/$CONF_FILE
		${CONF_DIR}d
		sleep 2
		${COIN_NAME}d masternode status
		echo -n $yel
		cat << _status
	#0 = Masternode not processed / initial state 
	#1 = Masternode capable
	#2 = Masternode not capable
	#3 = Masternode stoped
	#4 = Masternode input too new
	#6 = Masternode port not open
	#7 = Masternode port open
	#8 = Masternode sync in process 
	#9 = Masternode Remotely enabled
_status
	elif [ $choice = 6 ]; then
		echo "  ${yel}Removing old file ..."
		remove_file
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
	elif [ $choice = 7 ]; then
		exit
	else
		echo " ${yel} You must choice from 1-6. ${end}"
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
	echo "  ${red}Masternode IP:${end} $NODEIP:$PORT"
	echo "  ${red}Masternode PRIVATE KEY:${end} $PRIVATEKEY"
	echo -n $yel && echo
	${COIN_NAME}d
	sleep 2
	${COIN_NAME}d masternode status
	echo -n $red
	cat << _status
	#0 = Masternode not processed / initial state 
	#1 = Masternode capable
	#2 = Masternode not capable
	#3 = Masternode stoped
	#4 = Masternode input too new
	#6 = Masternode port not open
	#7 = Masternode port open
	#8 = Masternode sync in process 
	#9 = Masternode Remotely enabled
_status
	echo
	echo -n $yel
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

# DOWNLOAD NEEDED FILE
function download_file() {
	echo "${yel} Download needed file ...${end}"
	sleep 3
    wget https://github.com/MasterCoinOne/MasterCoin/releases/download/v1.1/MasterCoin-Wallet-daemon-1.1.0.zip
}

function install_firewall() {
	echo -e "Installing and setting up firewall to allow ingress on port ${yel}$PORT${end}"
	apt-get install -y ufw
	ufw allow $PORT comment "MC MN port" >/dev/null
	ufw allow ssh comment "SSH" >/dev/null 2>&1
	ufw limit ssh/tcp >/dev/null 2>&1
	ufw default allow outgoing >/dev/null 2>&1
	echo "y" | ufw enable >/dev/null 2>&1
}

# INSTALL SYSTEM
function install_system() {
	cd
	apt-get -y install unzip wget git curl
	sed -i '/cdrom/d' /etc/apt/sources.list
	grep -v '#' /etc/apt/sources.list
	apt update
	apt upgrade -y
	apt install htop
	touch /var/swap.img
	chmod 600 /var/swap.img
	dd if=/dev/zero of=/var/swap.img bs=1024k count=500
	mkswap /var/swap.img
	swapon /var/swap.img
	echo "/var/swap.img none swap sw 0 0" | tee --append /etc/fstab
	apt-get update -y
	apt-get upgrade -y
	apt-get dist-upgrade -y
	apt autoremove -y
	apt-get install nano htop git -y
	apt-get install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils software-properties-common -y
	apt-get install libboost-all-dev -y
	add-apt-repository ppa:bitcoin/bitcoin -y
	apt-get update -y
	apt-get install libdb5.3++ libboost-all-dev unzip pwgen libminiupnpc-dev -y
	apt-get install libdb5.3-dev libdb5.3++-dev -y
}

# INSTALL MASTERNODE
function install_mn() {
	cd
	chmod 775 MasterCoin-Wallet-daemon-1.1.0.zip
	unzip MasterCoin-Wallet-daemon-1.1.0.zip
	rm MasterCoin-Wallet-daemon-1.1.0.zip
	mv MasterCoind /usr/bin/MasterCoind
	echo ""
	read -r -p "  ${yel}Enter your PRIVATE KEY: $end" PRIVATEKEY
	
	cd
	mkdir -p $CONF_DIR
	echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> $CONF_DIR/$CONF_FILE
	echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> $CONF_DIR/$CONF_FILE
	echo "listen=1" >> $CONF_DIR/$CONF_FILE
	echo "server=1" >> $CONF_DIR/$CONF_FILE
	echo "daemon=1" >> $CONF_DIR/$CONF_FILE
	echo "logtimestamps=1" >> $CONF_DIR/$CONF_FILE
	echo "maxconnections=64" >> $CONF_DIR/$CONF_FILE
	echo "masternode=1" >> $CONF_DIR/$CONF_FILE
	echo "" >> $CONF_DIR/$CONF_FILE
	echo "port=$PORT" >> $CONF_DIR/$CONF_FILE
	echo "masternodeaddress=$NODEIP:$PORT" >> $CONF_DIR/$CONF_FILE
	echo "masternodeprivkey=$PRIVATEKEY" >> $CONF_DIR/$CONF_FILE
	MasterCoind -daemon
	echo "${yel}All done! Please start your masternode from your local wallet! ${end}"
}

# REMOVE OLD FILE
function remove_file () {
	${COIN_NAME}d stop
	rm -rf /usr/bin/MasterCoind
	rm -rf /root/.$COIN_NAME
}

function menu() {
	clear
	display_banner
	checks_ubuntu
	choice
}

menu
