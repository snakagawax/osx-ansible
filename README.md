# Mac OS X Setup

## Procedure
- Install Xcode from AppStore.

- Agree the license.
  ```
  $ sudo xcodebuild -license
  ```

- Launch Xcode and install required components.

- Install Command Line Tool.
  ```
  $ xcode-select --install
  ```
  If it is not able to install from cli, download Command Line Tool from [official website](https://developer.apple.com/download/more/) and install it.

- Create a script.
  ```
  $ cat << 'EOF' > requirement.sh
  #!bin/bash

  # install homebrew
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew doctor
  brew update

  # install ansible
  brew install ansible

  # git clone
  ANSIBLE_DIR=${HOME}/.ghq/github.com/snakagawax
  mkdir -p ${ANSIBLE_DIR}
  cd ${ANSIBLE_DIR}
  git clone https://github.com/snakagawax/osx-ansible.git
  cd osx-ansible
  EOF
  ```

- Run the script.
  ```
  $ chmod +x requirement.sh
  $ . requirement.sh
  ```

- Run playbook.
  ```
  $ ansible-playbook localhost.yml
  ```

## Reference
- https://github.com/knakayama/mac-os-x-setup
