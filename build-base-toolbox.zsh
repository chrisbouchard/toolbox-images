#!/usr/bin/env zsh

set -o errexit


local BOLD=$(tput bold)
local GREEN=$(tput setaf 2)
local WHITE=$(tput setaf 7)
local RESET=$(tput sgr0)

step() {
    echo
    echo "${BOLD}${GREEN}>>> ${WHITE}$1...${RESET}"
}


step 'Creating build cache directory'
mkdir -p .build/dnfcache

step 'Creating container'
container=$(buildah from registry.fedoraproject.org/f33/fedora-toolbox)
buildah config --label maintainer='Chris Bouchard <chris@upliftinglemma.net>' $container

step 'Adding nightly NeoVim repo'
buildah add $container \
    https://copr.fedorainfracloud.org/coprs/agriffis/neovim-nightly/repo/fedora-33/agriffis-neovim-nightly-fedora-33.repo \
    /etc/yum.repos.d/agriffis:neovim-nightly.repo

step 'Installing DNF dependencies'
buildah run --volume $PWD/.build/dnfcache:/var/cache/dnf:z $container \
    dnf install --assumeyes fzf neovim python-neovim ripgrep zsh

step 'Committing container'
buildah commit $container chrisbouchard/base-toolbox
buildah tag chrisbouchard/base-toolbox latest

