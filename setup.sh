#!/usr/bin/env bash

_prompt="`tput bold``tput setaf 171`"
_cmd_s=`tput setaf 123`
_out_s=`tput setaf 250`
_cmd_e=`tput sgr0`
_r=`tput sgr0`
RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

function _cmd() {
	echo -e "${_cmd_s}# ${@} ${_cmd_e}"
}

function _out() {
	echo -e "${_out_s}${@} ${_cmd_e}"
}

function welcome() {
	message=(
		"${_prompt}Let's walk you through your OS/developer environment setup"
		"Please follow along in another terminal to ensure everything goes smoothly"
		"NOTE: '#' means a command you should run in another terminal"
		"	Light gray output is the expected output of the command if relevant${_r}"
	)
	printf '%s\n' "${message[@]}"
}

function install-00-prereqs() {
	message=(
		"${_prompt}"
		"first xcode-developer tools need to be installed:"
		"${_r}"
		"$(_cmd xcode-select --install)"
	)
	printf '%s\n' "${message[@]}"

	message=(
		"${_prompt}"
		"brew must be installed"
		"use the following command to install brew:"
		"${_r}"
		"$(_cmd /bin/bash -c \"\$\(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh\)\")"
		"${_prompt}"
		"verify your brew installation:"
		"${_r}"
		"$(_cmd brew --version)"
		"$(_out 'Homebrew 3.4.6')"
		"$(_out 'Homebrew/homebrew-core (git revision 31925014726; last commit 2022-04-16)')"
		"$(_out 'Homebrew/homebrew-cask (git revision 7928ab0cdb; last commit 2022-04-16)')"
		""
	)

	printf '%s\n' "${message[@]}"
}

function install-01-python-build-dependencies() {
	message=(
		"${_prompt}"
		"additionally, you must install the python build dependencies"
		"NOTE: this should happen in your Apple Silicon environment"
		"test this is the case by running the following"
		"${_r}"
		"$(_cmd arch)"
		"$(_out arm64)"
		""
		"$(_cmd brew install libpq --build-from-source)"
		"$(_cmd brew install openssl readline sqlite3 xz zlib)"
	)
	printf '%s\n' "${message[@]}"
	
	OPENSSL=$(brew --prefix openssl@1.1)
	LIBPQ=$(brew --prefix libpq)

	LDFLAGS="-L${OPENSSL}/lib -L${LIBPQ}/lib"
	CPPFLAGS="-I${OPENSSL}/include -I${LIBPQ}/include"
	LPQPATH="${LIBPQ}/bin"

	message=(
		"${_prompt}"
		"we need to setup the correct environment to build some python packages eventually"
		"${_r}"
		"$(_cmd "cat >> ~/.zshenv \nexport LDFLAGS=\"${LDFLAGS}\"\nexport CPPFLAGS=\"${CPPFLAGS}\"\nexport PATH=\"\$PATH:${LPQPATH}\"")"
	)

	printf '%s\n' "${message[@]}"
}

function install-02-pyenv-install(){
	message=(
		"${_prompt}"
		'now by default (assuming a clean OSX environment) pyenv is not installed'
		"pyenv allows you to install new python versions very easily"
		"unfortunately there are some gotchas when using on OSX/Apple Silicon, let's get it setup correctly"
		"${_r}"
		"$(_cmd git clone https://github.com/pyenv/pyenv.git ~/.pyenv)"
		"$(_cmd 'cd ~/.pyenv && src/configure && make -C src')"
		"${_prompt}"
		"this should be a quick install - pyenv is purely shell scripts"
		"make sure pyenv python presets are configured (end with Ctrl-D):"
		"${_r}"
		"$(_cmd "cat >> .zshrc \nexport PATH=\"\$PATH:/Users/\$USER/.local/bin\"\nexport PYENV_ROOT=\"\$HOME/.pyenv\"\nexport PATH=\"\$PYENV_ROOT/bin:\$PATH\"\neval \"\$(pyenv init --path)\"\neval \"\$(pyenv init -)\"")"
		"${_prompt}"
		'now refresh your shell (or close and start a new one)'
		"${_r}"
		"$(_cmd source ~/.zshrc)"
		"$(_cmd pyenv versions)"
		"$(_out '* system (set by /Users/jklapacz/.pyenv/version)')"
		""
	)
	printf '%s\n' "${message[@]}"
}

function install-03-python-394() {
	message=(
		"${_prompt}"
		"we can now install python 3.9.4"
		"this is expected to be seamless"
		"${_r}"
		"$(_cmd pyenv install 3.9.4)"
		"$(_out '...lots of output maybe...')"
		"$(_cmd pyenv versions)"
		"$(_out '* system (set by /Users/jklapacz/.pyenv/version)')"
		"$(_out '3.9.4')"
		""
	)
	printf '%s\n' "${message[@]}"
}


function install-04-python-27() {
	message=(
	"${_prompt}we can now install python 2.7.18"
	"this is expected to be seamless${_r}"
	""
	"$(_cmd pyenv install 2.7.18)"
	"$(_out '...lots of output maybe...')"
	"$(_cmd pyenv versions)"
	"$(_out '* system (set by /Users/jklapacz/.pyenv/version)')"
	"$(_out '3.9.4')"
	"$(_out '2.7.18')"
	""
	)
	printf '%s\n' "${message[@]}"
}

function verify-installation() {
	python_versions=(2.7.18 3.8.6 3.9.4 3.10.4)
	for python_version in "${python_versions[@]}"; do
		mkdir -p /tmp/${python_version}
		pushd /tmp/${python_version}
			pyenv install ${python_version}
			pyenv local ${python_version}
			python -m pip install --upgrade pip
			python -m pip install cryptography psycopg2
			sleep 3
			python -c "import ssl; assert 'LibreSSL' not in ssl.OPENSSL_VERSION, 'LibreSSL implies system python - we expect OpenSSL'; print('ssl/openssl OK')"
			python -c "import psycopg2; assert psycopg2.extensions.libpq_version() > 140000, 'libpq installation has issues' ; print('psycopg2/libpq OK')"
			sleep 3
			echo -n "Continue? (y)? "
			read answer
		popd
	done
}

welcome

echo -n "Continue? (y)? "
read answer

install-00-prereqs

echo -n "Continue? (y)? "
read answer

install-01-python-build-dependencies

echo -n "Continue? (y)? "
read answer

install-02-pyenv-install

echo -n "Continue? (y)? "
read answer

install-03-python-394

echo -n "Continue? (y)? "
read answer

install-04-python-27

echo -n "Continue? (y)? "
read answer

#install-05-tricky-dependencies
#verify-installation
