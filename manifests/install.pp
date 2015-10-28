# == Class reaktor::install
#
# This class is called from reaktor for install.
#
class reaktor::install {

  $repodir = "${::reaktor::homedir}/reaktor"

  vcsrepo { $repodir:
    ensure   => present,
    provider => 'git',
    source   => $::reaktor::repository,
    user     => $::reaktor::user,
    notify   => Exec['reaktor_bundle_install']
  }

  exec { 'reaktor_bundle_install':
    command     => 'bundle install',
    cwd         => $repodir,
    path        => ['/bin', '/usr/bin', '/usr/local/bin'],
    refreshonly => true,
    user        => $::reaktor::user,
  }

  if $::reaktor::manage_user {
    group { $::reaktor::user:
      ensure => present,
      gid    => $::reaktor::gid
    } ->
    user { $::reaktor::user:
      ensure => present,
      home   => $::reaktor::homedir,
      uid    => $::reaktor::uid,
      gid    => $::reaktor::gid,
    } ->
    file { $::reaktor::homedir:
      ensure => directory,
      mode   => '0750',
      owner  => $::reaktor::user,
      group  => $::reaktor::gid,
    }

    Vcsrepo[$repodir] {
      require  => File[$::reaktor::homedir]
    }
  }
}
