#! /bin/bash

############################################################################################
#
# Copyright (c) 2014 Liu Ming (mlot@github.com)
# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use these files except in compliance with the License. 
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, 
# software distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License.
#
# Description: A handly script to setup a whole ssh tunnel proxy environment
# Version: v0.9
# Last Updated: 2014-11-30
# 
# Usage:
# 1. Setup the proxy environment: ./p.sh
#    Note: this shell is re-runable if current environment is corrupted.
# 2. Run through proxy: 
#    * p COMMAND, e.g.
#       p apt-get install docker.io
#       p wget www.facebook.com
#    * psh, run bash in  proxy mode 
#
############################################################################################
 
LOCAL_PROXY_IP=127.0.0.1
LOCAL_PROXY_PORT=7071

echo -n "Your proxy server:" && read -e proxy_server 
echo -n "Username:" && read -e proxy_user

identity_file="$HOME/.ssh/id_rsa_${proxy_server}_${proxy_user}"                                    

function check_passwordless_login() {
    echo "Testing passwordless login to the proxy server..."
    ssh -o 'PreferredAuthentications=publickey' -i $identity_file ${proxy_user}@${proxy_server} "hostname" > /dev/null 2>&1
}

function login_failed() {
    echo "Failed to login to the proxy server."
    exit 1
}

######### Main logic ##########
 
check_passwordless_login
if [ $? -ne 0 ]; then
    echo "Setup passwordless login..."
    if [ ! -f ${identity_file} ]; then                                                                 
	echo "Generating ssh key..."
        ssh-keygen -b 2048 -t rsa -f ${identity_file} -q -N ''                                    
    fi

    echo "Copying id to proxy server..."
    ssh-copy-id -i $identity_file ${proxy_user}@${proxy_server}           
    if [ $? -ne 0 ]; then
        echo "copy failed"
        login_failed
    fi

    check_passwordless_login
    if [ $? -ne 0 ]; then
        echo "failed"
        login_failed
    fi
fi

echo
echo "Check software installation..."
sudo apt install -y proxychains autossh  
echo 'Waiting for cleaning autossh daemon...' && sudo killall -9 autossh && sleep 5
echo 'Start autossh daemon...' 
autossh -Nf -i $identity_file -D $LOCAL_PROXY_IP:$LOCAL_PROXY_PORT ${proxy_user}@${proxy_server}         

sudo sed -i "s/socks4\s\s127.0.0.1\s9050/socks5 $LOCAL_PROXY_IP $LOCAL_PROXY_PORT/" /etc/proxychains.conf
sudo sed -i "s/#quiet_mode/quiet_mode/" /etc/proxychains.conf

if [ ! -f /usr/bin/p ]; then
    sudo ln -s /usr/bin/proxychains /usr/bin/p                                                         
fi

if [ ! -f /usr/bin/psh ]; then
    #echo "proxychains bash --rcfile <(cat ~/.bashrc; echo 'PS1="(p)$PS1"')" > /usr/bin/psh
    sudo sh -c "echo 'proxychains bash --rcfile <(cat ~/.bashrc; echo PS1='\"'\"'(p)\$PS1'\"')\" > /usr/bin/psh"
    sudo chmod a+x /usr/bin/psh
fi

echo
echo "============================================================================================="
echo "Proxy enviroment has been setup successfully, you can use it in 3 ways:"
echo "1. prepend 'p' to your command, redirecting all network traffic to:$proxy_server, like:"
echo '    $p apt-get install mysql'
echo '    $p git clone https://github.com/mlot/easy-proxy.git'
echo 
echo "2. start a bash in proxy mode, by issue:"
echo '    $psh'
echo
echo "3. Config socks5 proxy in your apps with: socks5://$LOCAL_PROXY_IP:$LOCAL_PROXY_PORT"
echo "============================================================================================="
echo
