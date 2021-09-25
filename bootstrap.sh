#!/bin/bash

# Install mint if needed
which mint > /dev/null || {
  git clone https://github.com/yonaskolb/Mint.git
  pushd Mint
  ## Since 0.17.0 Mint has changed $MINT_PATH and $MINT_LINK_PATH
  ## which needs manually adding these paths to $PATH.
  ## This made it tricky to install mint with mint
  ## so temporarily using `make` instead of `mint install`
  make
  popd
}

# Install dependencies via mint
mint bootstrap

# Generate Xcode project file via xcodegen
mint run xcodegen generate
