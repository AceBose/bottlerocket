#!/bin/bash
sudo yum groupinstall "Development Tools" -y
sudo yum install make automake gcc openssl openssl-devel pkg-config lz4 perl-FindBin perl-lib -y
git clone https://github.com/bottlerocket-os/bottlerocket.git
cd bottlerocket
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# -y command 1 is to run default setup
source $HOME/.cargo/env
cargo install cargo-make
cargo install cargo-deny --version 0.6.2

# install docker 
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo reboot
