#!/bin/sh
#
# mjeffe's profile stuff for *nix boxes
#
# Should be cloned to $HOME/src/
#

this=`basename $0`
BASEDIR=$HOME/src
# companion projects
NIX_UTILS=$BASEDIR/mrj/nix-utils
JAMESTOOLS=$BASEDIR/acx/sawmill/jamestools
MAKE_MACHINE=`uname -s | tr [a-z] [A-Z]`

_safe_copy() {
    local src="$1"
    local dest="$2"
    local opts=

    if test -z $src -o -z $dest; then
        echo "'source' or 'destination' argument was missing"
        exit 1
    fi

    echo "  installing $dest"
    if test -f $dest -o -d $dest; then
        echo "    $dest exits, renaming to ${dest}.$$"
        mv $dest ${dest}.$$
    fi

    # handle copying directories
    if test -d $src; then
        opts="$opts -r"
    fi
    cp $opts $src $dest
}


# ------------
# base profile stuff
# ------------
echo $this: installing profile files

# ubuntu seems to prefer .profile over .bash_profile
_safe_copy ./bash_profile $HOME/.profile-mrj
cat <<EOF >> $HOME/.profile

# add my stuff
export MAKE_MACHINE=$MAKE_MACHINE
. ~/.profile-mrj
EOF

# append my bashrc to the end of default
_safe_copy ./bashrc $HOME/.bashrc-mrj
cat <<EOF >> $HOME/.bashrc

# add my stuff
. ~/.profile-mrj
EOF

_safe_copy ./gitconfig $HOME/.gitconfig
_safe_copy ./Xdefaults $HOME/.Xdefaults
_safe_copy ./conky.conf $HOME/.config/conky/conky.conf

echo $this: installing default crontab
crontab crontab.default
    
# ------------
# vim stuff
# ------------
echo $this: installing custom vim stuff

_safe_copy ./vimrc $HOME/.vimrc
_safe_copy ./vimrc-ide $HOME/.vimrc-ide
_safe_copy ./vim $HOME/.vim
# "install" Vundle directly into the .vim/ dir
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
# install all my vim plugins
vim -u ~/.vimrc-ide -n -c PluginInstall  -c exit -c exit

# ------------
# ssh stuff TODO: handle this as ln -s from Dropbox's db_crypt (check if .ssh is already a symlink...)
# ------------
#echo $this: installing custom ssh stuff

#_safe_copy ./ssh $HOME/.ssh

# ------------
# my common ~/bin utilities
# ------------
echo $this: installing nix-utils

if test -d $NIX_UTILS; then
    cd $NIX_UTILS/src/
    make install
    make install_all
else
    echo "$this:   dir: $NIX_UTILS"
    echo "$this:   unable to find common utilities project, skipping..."
fi

# ------------
# compile tools
# ------------

if test $MAKE_MACHINE"x" = "x"; then
    echo "MAKE_MACHINE is not set."
    exit 1
fi

# check to make sure jamestools has been checked out before trying to run
if test ! -d $JAMESTOOLS; then
    echo "$this: It looks like jamestools has not been checked out, skipping..."
else
    (cd $JAMESTOOLS && ./install_essentials_locally.sh)
fi


