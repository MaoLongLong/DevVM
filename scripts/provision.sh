#!/usr/bin/env bash

set -euxo pipefail

while [[ "$#" -gt 0 ]]; do
    case $1 in
    --apt-mirrors)
        APT_MIRRORS="$2"
        shift
        ;;
    --docker-mirrors)
        DOCKER_MIRRORS="$2"
        shift
        ;;
    --registry-mirrors)
        REGISTRY_MIRRORS="$2"
        shift
        ;;
    --go-version)
        GO_VERSION="$2"
        shift
        ;;
    --go-proxy)
        GOPROXY="$2"
        shift
        ;;
    *)
        echo "unknown option: $1"
        exit 1
        ;;
    esac
    shift
done

sudo sed -i "s/archive.ubuntu.com/${APT_MIRRORS}/g" /etc/apt/sources.list
sudo sed -i "s/security.ubuntu.com/${APT_MIRRORS}/g" /etc/apt/sources.list
sudo apt-get -y update
sudo apt-get -y install \
    bash-completion \
    build-essential

sudo apt-get -y install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL "https://${DOCKER_MIRRORS}/linux/ubuntu/gpg" | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://${DOCKER_MIRRORS}/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io

sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-EOF
{
  "registry-mirrors": ["${REGISTRY_MIRRORS}"]
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
sudo usermod -aG docker vagrant

curl -fsSL "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tgz
sudo tar -C /usr/local -xzf /tmp/go.tgz

tee -a /home/vagrant/.profile <<-'EOF'
export GOROOT=/usr/local/go
export GOPATH=/home/vagrant/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
EOF
# shellcheck disable=SC1091
source /home/vagrant/.profile
mkdir -p /home/vagrant/go/{bin,pkg,src}
go env -w GO111MODULE=on
go env -w GOPROXY="${GOPROXY}"
