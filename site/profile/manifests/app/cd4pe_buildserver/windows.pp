class profile::app::cd4pe_buildserver::windows {
  file { 'c:/tmp':
    ensure   => directory,
  }

  file { 'Puppet Development Kit download':
    ensure   => present,
    source   => 'https://puppet-pdk.s3.amazonaws.com/pdk/1.5.0.0/repos/windows/pdk-1.5.0.0-x64.msi',
    path     => 'c:/tmp/pdk-1.5.0.0-x64.msi',
    checksum => 'mtime',
    require  => File['c:/tmp'],
  }

  package { 'Puppet Development Kit':
    ensure   => present,
    source   => 'c:/tmp/pdk-1.5.0.0-x64.msi',
    provider => 'windows',
    require => File['Puppet Development Kit download'],
  }

  ensure_packages(['Wget','git'], { ensure => present, provider => 'chocolatey' })


  # Install Ruby 2.4.1 and the devkit - have to use EXEC because puppet doesn't source HTTPS with untrusted CERTS!!!!!!!
  exec { 'Ruby and DevKit File':
    command => 'C:\ProgramData\chocolatey\bin\wget.exe https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-2.4.4-1/rubyinstaller-devkit-2.4.4-1-x64.exe -O c:/tmp/rubyinstaller-devkit-2.4.4-1-x64.exe --no-check-certificate',
    unless  => 'c:\windows\system32\cmd.exe /c type c:\tmp\rubyinstaller-devkit-2.4.4-1-x64.exe',
  }

  package { 'Ruby 2.4.4-1-x64 with MSYS2':
    ensure    => present,
    source    => 'c:/tmp/rubyinstaller-devkit-2.4.4-1-x64.exe',
    provider  => 'windows',
    install_options => ['/tasks="assocfiles,modpath"', '/silent'],
    require   => Exec['Ruby and DevKit File'],
  }

  # If this cacert isn't placed and used, ruby version managers will croak
  file { 'C:/cacert':
    ensure    => directory,
    group     => 'Administrators',
  }

  file { 'Cacert File':
    ensure    => present,
    source    => 'http://curl.haxx.se/ca/cacert.pem',
    group     => 'Administrators',
    path      => 'C:/cacert/cacert.pem',
    require   => File['C:/cacert'],
  }

  windows_env {'SSL_CERT_FILE':
    ensure    => present,
    variable  => 'SSL_CERT_FILE',
    value     => 'c:/cacert/cacert.pem',
    mergemode => clobber,
  }

  # Download Unleashed Ruby Version manager
  exec { 'uru.0.8.5 installer':
    command  => 'C:\ProgramData\chocolatey\bin\wget.exe https://bitbucket.org/jonforums/uru/downloads/uru.0.8.5.nupkg -o c:\tmp\uru.0.8.5.nupkg --no-check-certificate',
    unless   => 'c:\windows\system32\cmd.exe /c type c:\tmp\uru.0.8.5.nupkg',
    require  => File['Cacert File'],
  }

  package { 'uru.0.8.5.nupkg':
    ensure   => present,
    provider => 'chocolatey',
    source   => 'c:/tmp',
    require  => Exec['uru.0.8.5 installer'],
    notify   => Exec['Add 2.4 as ruby env in uru'],
  }

  exec { 'Add 2.4 as ruby env in uru':
    command  => 'C:\ProgramData\chocolatey\bin\uru.bat admin add C:\Ruby24-x64\bin',
  }
}
