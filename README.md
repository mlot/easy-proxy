easy-proxy
==========

A Bash script to setup autossh proxy environment for debian serias, combine ssh, autossh and proxychains.

Usage:
1. Setup the proxy environment: ./p.sh
   this shell is re-runable if current environment is corrupted.
2. Run through proxy:
  * p COMMAND, e.g.
     `p apt-get install docker.io`
     `p wget www.facebook.com`
  * psh, run bash in  proxy mode
