#!/usr/bin/env bash

function install-00-prereqs() {
	message=(
		"first xcode-developer tools need to be installed:"
		""
		'$ xcode-select --install'
		""
	)
	printf '%s\n' "${message[@]}"

	message=(
		"brew must be installed"
		"use the following command to install brew:"
		""
		'$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)'
		""
		"verify your brew installation:"
		""
		'$ brew --version'
		"Homebrew 3.4.6"
		'Homebrew/homebrew-core (git revision 31925014726; last commit 2022-04-16)'
		'Homebrew/homebrew-cask (git revision 7928ab0cdb; last commit 2022-04-16)'
		""
	)

	printf '%s\n' "${message[@]}"
}

function install-01-python-build-dependencies() {
	message=(
		"additionally, you must install the python build dependencies"
		"NOTE: this should happen in your Apple Silicon environment"
		"test this is the case by running the following"
		""
		'$ arch'
		"arm64"
		""
		'$ brew install libpq --build-from-source'
		'$ brew install openssl readline sqlite3 xz zlib'
	)
	printf '%s\n' "${message[@]}"
	
	OPENSSL=$(brew --prefix openssl@1.1)
	LIBPQ=$(brew --prefix libpq)

	LDFLAGS="-L${OPENSSL}/lib -L${LIBPQ}/lib"
	CPPFLAGS="-I${OPENSSL}/include -I${LIBPQ}/include"
	LPQPATH="${LIBPQ}/bin"

	message=(
		""
		"we need to setup the correct environment to build some python packages eventually"
		""
		"$ cat >> ~/.zshenv "
		"export LDFLAGS=\"${LDFLAGS}\""
		"export CPPFLAGS=\"${CPPFLAGS}\""
		"export PATH=\"\$PATH:${LPQPATH}\""
		""
	)

	printf '%s\n' "${message[@]}"
}

function install-02-pyenv-install(){
	message=(
		'now by default (assuming a clean OSX environment) pyenv is not installed'
		"pyenv allows you to install new python versions very easily"
		"unfortunately there are some gotchas when using on OSX/Apple Silicon, let's get it setup correctly"
		""
		'$ git clone https://github.com/pyenv/pyenv.git ~/.pyenv'
		'$ cd ~/.pyenv && src/configure && make -C src'
		""
		"this should be a quick install - pyenv is purely shell scripts"
		"make sure pyenv python presets are configured (end with Ctrl-D):"
		""
		'$ cat >> .zshrc'
		'export PATH="$PATH:/Users/$USER/.local/bin"'
		'export PYENV_ROOT="$HOME/.pyenv"'
		'export PATH="$PYENV_ROOT/bin:$PATH"'
		'eval "$(pyenv init --path)"'
		'eval "$(pyenv init -)"'
		""
		'now refresh your shell (or close and start a new one)'
		""
		'$ source ~/.zshrc'
		'$ pyenv versions'
		'* system (set by /Users/jklapacz/.pyenv/version)'
	)
	printf '%s\n' "${message[@]}"
}

function install-03-python-394() {
	message=(
	"we can now install python 3.9.4"
	"this is expected to be seamless"
	""
	'$ pyenv install 3.9.4'
	"...lots of output maybe..."
	'$ pyenv versions'
	'* system (set by /Users/jklapacz/.pyenv/version)'
	'3.9.4'
	)
	printf '%s\n' "${message[@]}"
}


function install-04-python-27() {
	message=(
	"we can now install python 2.7.18"
	"this is expected to be seamless"
	""
	'$ pyenv install 2.7.18'
	"...lots of output maybe..."
	'$ pyenv versions'
	'* system (set by /Users/jklapacz/.pyenv/version)'
	'2.7.18'
	'3.9.4'
	)
	printf '%s\n' "${message[@]}"
}

function install-05-tricky-dependencies() {
	message=(
	''
	'$ mkdir -p /tmp/py2 && cd /tmp/py2 && pyenv local 2.7.18'
	'$ python -m pip install cryptography'
	'$ python -m pip install psycopg2'
	'$ mkdir -p /tmp/py3 && cd /tmp/py3 && pyenv local 3.9.4'
	'$ python -m pip install cryptography'
	'$ python -m pip install psycopg2'
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

install-00-prereqs
install-01-python-build-dependencies
install-02-pyenv-install
install-03-python-394
install-04-python-27
install-05-tricky-dependencies
verify-installation
