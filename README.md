# Mac OS X Setup

## Procedure

1. Install Xcode from AppStore.

2. Agree the license.
```
sudo xcodebuild -license
```

3. Launch Xcode and install required components.

4. Install Command Line Tool.
```
xcode-select --install
```
If it is not able to install from cli, download Command Line Tool from [official website](https://developer.apple.com/download/more/) and install it.

5. Create a script.
```
cat << 'EOF' > requirement.sh
#!/bin/bash

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
softwareupdate --all --install --force
brew doctor
brew update

# install ansible
brew install ansible

# git clone
ANSIBLE_DIR=${HOME}/ghq/github.com/snakagawax
mkdir -p ${ANSIBLE_DIR}
cd ${ANSIBLE_DIR}
git clone https://github.com/snakagawax/osx-ansible.git
cd osx-ansible
EOF
```

6. Run the script.
```
chmod +x requirement.sh
. ./requirement.sh
```

7. Run playbook.
```
ansible-playbook localhost.yml -K
```

8. Run [post setup](docs/post-setup.md).

## Reference
- https://github.com/knakayama/mac-os-x-setup
