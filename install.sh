#! /bin/bash

# INSTALLING GENERAL PROGRAMS
sudo apt update
if [ ! $(which vim) ]
then
	sudo apt install vim -y
fi

if [ ! $(which git) ]
then
	sudo apt install git -y
fi

if [ ! $(which tmux) ]
then
	sudo apt install tmux -y
fi

if [ ! $(which curl) ]
then
	sudo apt install curl -y
fi

if [ ! $(which zsh) ]
then
	sudo apt install zsh -y
fi

if [ ! $(which xclip) ]
then
	sudo apt install xclip -y
fi

# INSTALL  OHMYZSH
if [ ! $(sed -n '/ohmyzsh/p' ~/.zshrc) ]; then
	echo y | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	sed -i '/^#\ export\ PATH.*/s/^# //' ~/.zshrc
	sed -i '/^ZSH_THEME/s/".*"/"avit"/' ~/.zshrc
fi

# START TERMINAL WITH TMUX
if [[ ! $(grep tmux ~/.zshrc) ]]; then
	echo '
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
	exec tmux
fi' >> ~/.zshrc
fi

# MAKE ZSH DEFAULT SHELL AND REBOOT
if [ $(echo $SHELL) != "/usr/bin/zsh" ]; then
	SCRIPT="bash ~/Desktop/SetupUbuntu/install.sh"
	echo "$SCRIPT #apagar" >> ~/.zshrc
	chsh -s $(which zsh)
	sudo reboot
else
	sed -i "/#apagar/ d" ~/.zshrc
fi

# CONFIGURE GIT USER AND EMAIL && FIX GIT BRANCH AND LOG
if [[ ! $(cat ~/.gitconfig) ]]; then
	read -p "Enter git username: " GITNAME
	git config --global user.name "$GITNAME"
	read -p "Enter git email: " GITMAIL 
	git config --global user.email "$GITMAIL"
	git config --global core.pager cat
	git config --global core.editor "vim"
fi

# INSTALL PYTHON
if [ ! $(which python) ]; then
	sudo apt install python -y
fi
# INSTALL PYENV
if [ ! $(which pyenv) ]; then
	sudo apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
	libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
	xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
	curl https://pyenv.run | bash
	export PATH="$HOME/.pyenv/bin:$PATH"
	echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.zshrc
	echo 'eval "$(pyenv init -)"' >> ~/.zshrc
	echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc
	source ~/.zshrc
	pyenv install 3.7.7
	pyenv global 3.7.7
	pyenv virtualenv 3.7.7 tools
	pyenv activate tools
	pip install poetry
	pyenv deactivate
	pyenv global 3.7.7 tools
	poetry config virtualenvs.in-project true
fi
	
# COPY DOTFILES
cp -r ~/Desktop/SetupUbuntu/dotfiles/.tmux.conf ~/
cp -r ~/Desktop/SetupUbuntu/dotfiles/.vim ~/
cp -r ~/Desktop/SetupUbuntu/dotfiles/.vimrc ~/

# INSTALL FONTS
if [ ! $(fc-list | grep inconsolata) ]; then
	sudo apt install fonts-inconsolata -y
fi

# INSTALL TWEAK TOOLS AND FLAT REMIX THEME
if [ ! $(which gnome-tweaks) ]; then
	sudo apt install gnome-tweak-tool
fi
if [ ! -d ~/.icons ]; then
	mkdir ~/.icons && mkdir ~/.themes
	git clone https://github.com/daniruiz/flat-remix ~/.icons/
	git clone https://github.com/daniruiz/flat-remix-gtk ~/.themes
fi

# INSTALL DOCKER
if [ ! $(which docker) ]; then
	sudo apt update -y
	sudo apt install \
			 apt-transport-https \
			 ca-certificates \
			 gnupg-agent \
			 software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository \
			 "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
			 $(lsb_release -cs) \
			 stable"
	sudo apt update
	sudo apt-get install docker-ce docker-ce-cli containerd.io -y
	#DOCKER PERMISSIONS (USING WITHOUT SUDO)
	sudo groupadd docker
	sudo usermod -aG docker $USER
fi
	
# INSTALL NVM
if [ ! $(which nvm) ]; then
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
	echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm' >> ~/.zshrc
fi

# INSTALL NODE
. ~/.nvm/nvm.sh
. ~/.profile
. ~/.bashrc
nvm install lts/erbium
# INSTALL SERVERLESS
npm install -g serverless


# INSTALL AWS
if [ ! $(which aws) ]; then
	sudo apt install awscli -y
fi

sudo reboot
