# easy-proxy #
==========

A handy script to setup a proxy environment to redirect all your application traffic to another sshd enabled server.
Combined with ssh, autossh and proxychains, very easy to use, no configuration needed.


## Usage: ##
1. Setup the proxy environment: 
   * `./p.sh`
   * Follow the prompt, enter the proxy server address, username and password
   * The script will:
      * test and generate(if necessary) passwordless ssh login environment between your host and the proxy server
      * build ssh tunnel with -D option to setup a local socks5 server
      * add autossh daemon to supervise this ssh tunnel, will rebuild the connection when it breaks
      * config proxychains to work with the ssh tunnel built above
      * add p and psh short commands to simplify usage
   * This shell is re-runable if current environment is corrupted.
2. Run through proxy:
  * p COMMAND, e.g.
     * `p apt-get install docker.io`
     * `p wget www.facebook.com`
     * `p git clone https://github.com/mlot/easy-proxy.git`
  * Or use 'psh', to run a shell all in proxy environment
      * `psh`
