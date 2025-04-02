#!/usr/bin/env zsh


function installLazyGit() {
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazygit.tar.gz lazygit
	sudo install lazygit -D -t /usr/local/bin/
	rm -rf lazygit
	rm -rf lazygit.tar.gz
}

function pythonSupportForVimspector() {
	pyenv virtualenv nvim
	pyenv activate nvim
	pip install pynvim
	pyenv deactivate
}

# fd dep for telescope
# xclip for yank to system clipboard
# pynvim used for vimspector support (requires venv as per checkhealth 'advice')
case $(uname -s) in
	"Linux")
	sudo apt update -y
	sudo apt install xclip lua3.5 fd-find -y
	pythonSupportForVimspector
	installLazyGit
	;;
	"Darwin")	
	pythonSupportForVimspector
        brew install lazygit fd pynvim
	;;
	*)
	echo "windows?!"
	;;
esac

if ! alias | grep nvim ; then
	echo "alias vim='nvim'" >> ~/.zshrc
	source ~/.zshrc
fi
