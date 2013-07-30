
class prm_cman( ) {

  $releasever = "6"
  $basearch = $hardwaremodel
  $extension = "rhel$releasever.$basearch.rpm"  
  
	yumrepo { 
    "percona":
      descr       => "Percona",
      enabled     => 1,
      baseurl     => "http://repo.percona.com/centos/$releasever/os/$basearch/",
      gpgcheck    => 0;
	}
  
  $enhancers = ["pacemaker", "cman", "pcs", "ccs", "resource-agents" ]
  package { $enhancers: ensure => "installed" }
  
  $percona_packages = ["percona-xtrabackup", "Percona-Server-server-55"]
  
  package { 
    $percona_packages: 
    ensure => "installed",
    require => Yumrepo['percona'] 
  }
  
  file { "hosts":
    path => "/etc/hosts",
    ensure => file,
    content => template("prm_cman/hosts.erb"),
  }
  
 
  
  file { "cluster.conf":
    path => "/etc/cluster/cluster.conf",
    ensure => file,
    owner => root,
    group => root,
    mode  => 644,
    source => "puppet:///modules/prm_cman/cluster.conf",
    require => Package["cman"],
  }  
  
  exec {"quorum_timeout":
    command => "echo 'CMAN_QUORUM_TIMEOUT=0' >> /etc/sysconfig/cman",
    path    => "/bin",
    unless => "grep 'CMAN_QUORUM_TIMEOUT=0' /etc/sysconfig/cman 2>/dev/null",
    require => Package["cman"],
  }
  
  service { "cman":
    enable => true,
    ensure => running,
    require => [File["cluster.conf"], Exec["quorum_timeout"]],
  }
  
  service {"pacemaker":
    enable => true,
    ensure => running,
    require => Service["cman"]
  }
  
}