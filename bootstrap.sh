#!/bin/zsh

# Fail whole script when any step fails
set -e

# Mint installation function
function install_mint() {
  git clone https://github.com/yonaskolb/Mint.git
  pushd Mint
  ## Since 0.17.0 Mint has changed $MINT_PATH and $MINT_LINK_PATH
  ## which needs manually adding these paths to $PATH.
  ## This made it tricky to install mint with mint
  ## so temporarily using `make` instead of `mint install`
  make
  popd
  rm -rf Mint
}

# Install mint if needed
type mint > /dev/null || install_mint

# Install dependencies via mint
mint bootstrap

# Generate Xcode project file via xcodegen
mint run xcodegen generate
