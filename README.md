# Dotfiles

To install stuff

1. Install Homebrew with 

``` shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Note that I needed to specify `/usr/bin/curl` for some reason.

2. Download a (temporary) babashka install and place it on your path
   These can be found here: https://github.com/babashka/babashka/releases


3. Run `bb brew-install` and `bb link-dotfiles` to set things up.

# TODO
Write scripts to do those things called "bootstrap" or something
