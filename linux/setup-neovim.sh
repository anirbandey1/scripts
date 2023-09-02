#!/bin/sh

show_help(){

	cat << EOF
setup-neovim.sh

Choose one of the available commands:
	install
	clean
	config
	help | --help | -h

EOF


}

sudo_mode=true
package_location="${HOME}/.local/share/neovim"
install_location="/usr/local/bin"

package_location_sudo="/opt/neovim"
install_location_sudo="/usr/local/bin"

remove_package() {

rm -rv "${package_location}"
sudo rm -v "${install_location}/nvim"

}

install_package_appimage() {

mkdir -pv "${package_location}"
cd "${package_location}"

curl -LJO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
chmod --verbose +x nvim.appimage
./nvim.appimage --appimage-extract

sudo ln -sv "${package_location}/squashfs-root/usr/bin/nvim" "${install_location}"

}

install_package_tarball() {

mkdir -pv "${package_location}"
cd "${package_location}"

curl -LJO https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz
tar -xvzf nvim-linux64.tar.gz

sudo ln -sv "${package_location}/nvim-linux64/bin/nvim" "${install_location}"

}


remove_package_sudo() {

sudo rm -rv "${package_location_sudo}"
sudo rm -v "${install_location_sudo}/nvim"

}

install_package_appimage_sudo() {

sudo mkdir -pv "${package_location_sudo}"
cd "${package_location_sudo}"

sudo curl -LJO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
sudo chmod --verbose +x nvim.appimage
sudo ./nvim.appimage --appimage-extract

sudo ln -sv "${package_location_sudo}/squashfs-root/usr/bin/nvim" "${install_location_sudo}"

}

install_package_tarball_sudo() {

sudo mkdir -pv "${package_location_sudo}"
cd "${package_location_sudo}"

sudo curl -LJO https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz
sudo tar -xvzf nvim-linux64.tar.gz

sudo ln -sv "${package_location_sudo}/nvim-linux64/bin/nvim" "${install_location_sudo}"

}



install_packer() {

# Clone packer plugin manager

git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

}

clone_my_config() {

git clone git@github.com:anirbandey1/nvim.git ~/.config/nvim

git clone https://github.com/anirbandey1/nvim.git ~/.config/nvim

}

_config() {

  install_packer
  clone_my_config

}

_clean() {
  if [ $sudo_mode ]; then 
    remove_package_sudo
  else 
    remove_package
  fi

}


_install_options(){


  echo "Install neovim options :- "
  echo "1. Install neovim as appimage"
  echo "2. Install neovim as tarball"
  printf "Enter your option : "
  read _option

  case "${_option}" in
  "1")
    echo "Installing appimage"
    if [ $sudo_mode ];then 
      install_package_appimage_sudo
    else 
      install_package_appimage
    fi
    ;;
  "2")
    echo "Installing tarball"
    if [ $sudo_mode ]; then
      install_package_tarball_sudo
    else 
      install_package_tarball
    fi
    ;;
  *)
    echo "Invalid option."
    ;;
esac


}



main() {
    
    if [ $sudo_mode ]; then
      printf "Running in sudo mode \n"
    else 
      printf "Running in regular user mode \n"
    fi

	case "$1" in 
		(install)
			shift
			_install_options "$@"
			;;
		(config)
			shift
			_config "$@"
			;;
		(clean)
			shift
			_clean "$@"
			;;
		(help | --help | -h)
			show_help 
			exit 0 
			;;
		(*)
			printf >&2 "Error: invalid command\n"
			show_help
			exit 1
			;;

	esac
	

}



main "$@"
