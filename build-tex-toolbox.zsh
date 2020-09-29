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
mkdir -p .build/{dnfcache,texlab}

step 'Downloading TexLab'
curl --location --output .build/texlab-x86_64-linux.tar.gz \
    https://github.com/latex-lsp/texlab/releases/latest/download/texlab-x86_64-linux.tar.gz
tar --verbose --extract --gzip --directory=.build/texlab --recursive-unlink \
    --file=.build/texlab-x86_64-linux.tar.gz

step 'Creating container'
container="$(buildah from localhost/chrisbouchard/base-toolbox)"

step 'Installing TexLab'
buildah add "$container" .build/texlab/texlab /usr/local/bin/texlab

step 'Installing DNF dependencies'
buildah run --volume $PWD/.build/dnfcache:/var/cache/dnf:z "$container" \
    dnf install --assumeyes make texlive-scheme-full

step 'Committing container'
buildah commit "$container" chrisbouchard/tex-toolbox

