# @summary Insatll and configure vim for puppet
# @param user User account name
# @param group User account group name
# @param install_rust_vim If true this puppet module install rust-vim
# @param install_vim_airline If true this puppet module install vim-airline
# @param install_vim_json If true this puppet module install vim-json
# @param install_vim_puppet If true this puppet module install vim-puppet
# @param install_vim_ruby If true this puppet module install vim-ruby
# @param install_yaml_vim If true this puppet module install yaml-vim

class vim (
  String[1] $user  = 'tongue',
  String[1] $group = 'tongue',

  Boolean $install_rust_vim    = true,
  Boolean $install_vim_airline = true,
  Boolean $install_vim_json    = true,
  Boolean $install_vim_puppet  = true,
  Boolean $install_vim_ruby    = true,
  Boolean $install_yaml_vim    = true,
) {
  package { 'vim':
    ensure => present,
    name   => 'vim',
  }

  file { "/home/${vim::user}/.vimrc":
    ensure  => file,
    mode    => '0644',
    owner   => $vim::user,
    group   => $vim::group,
    content => epp('vim/vimrc.epp'),
    replace => true,
    recurse => false,
    require => Package['vim'],
  }

  file { "/home/${vim::user}/.vim/pack/plugins/start/":
    ensure  => directory,
    recurse => true,
    owner   => $vim::user,
    group   => $vim::group,
    mode    => '0755',
    require => File["/home/${vim::user}/.vimrc"],
  }

  $plugins = {
    'rust.vim' => {
      'url'     => 'https://github.com/rust-lang/rust.vim.git',
      'install' => $install_rust_vim,
    },
    'vim-airline'   => {
      'url'     => 'https://github.com/vim-airline/vim-airline.git',
      'install' => $install_vim_airline,
    },
    'vim-json'      => {
      'url'     => 'https://github.com/elzr/vim-json.git',
      'install' => $install_vim_json,
    },
    'vim-puppet'    => {
      'url'     => 'https://github.com/rodjek/vim-puppet.git',
      'install' => $install_vim_puppet,
    },
    'vim-ruby'      => {
      'url'     => 'https://github.com/vim-ruby/vim-ruby.git',
      'install' => $install_vim_ruby,
    },
    'yaml-vim'      => {
      'url'     => 'https://github.com/stephpy/vim-yaml.git',
      'install' => $install_yaml_vim,
    },
  }

  $plugins.each |String $name, Hash $details| {
    if $details['install'] {
      vcsrepo { "/home/${vim::user}/.vim/pack/plugins/start/${name}":
        ensure   => present,
        provider => git,
        source   => $details['url'],
        owner    => $vim::user,
        group    => $vim::group,
        require  => File["/home/${vim::user}/.vim/pack/plugins/start/"],
      }
    }
  }
}
