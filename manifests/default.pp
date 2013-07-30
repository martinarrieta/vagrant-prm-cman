# -*- mode: ruby -*-
# vi: set ft=ruby :

node default {
  
  service { "iptables":
    enable => false,
    ensure => stopped,
  }
  include prm_cman
}
