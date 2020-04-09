#!/bin/sh
#
# $Id$
#

WD=`pwd`
this=`basename $0`
JAMESTOOLS=/home/mjeffe/src/acx/sawmill/jamestools

# ------------
# base profile stuff
# ------------
echo $this: installing profile files

if test -f $HOME/.bashrc; then
    echo "$this: $HOME/.bashrc exits, renaming to $HOME/.bashrc.$$"
    mv $HOME/.bashrc $HOME/.bashrc.$$
fi
cp ./bashrc $HOME/.bashrc

if test -f $HOME/.bash_profile; then
    echo "$this: $HOME/.bash_profile exits, renaming to $HOME/.bash_profile.$$"
    mv $HOME/.bash_profile $HOME/.bash_profile.$$
fi 
cp bash_profile $HOME/.bash_profile 
echo -e "\nexport MAKE_MACHINE=$MAKE_MACHINE" >> $HOME/.bash_profile
    
if test -f $HOME/.Xdefaults; then
    echo $this: $HOME/.Xdefaults exits, renaming to $HOME/.Xdefaults.$$
    mv $HOME/.Xdefaults $HOME/.Xdefaults.$$
fi 
cp Xdefaults $HOME/.Xdefaults

if test -f $HOME/.config/conky/conky.conf; then
    echo "$this: $HOME/.config/conky/conky.conf exits, renaming to $HOME/.config/conky/conky.conf.$$"
    mv $HOME/.config/conky/conky.conf $HOME/.config/conky/conky.conf.$$
fi 
cp conkyrc $HOME/.config/conky/conky.conf
    
# ------------
# vim stuff
# ------------
echo $this: installing custom vim stuff

if test -f $HOME/.vim; then
    echo "$this: $HOME/.vim exits, renaming to $HOME/.vim.$$"
    mv $HOME/.vim $HOME/.vim.$$
fi 
cp -r vim $HOME/.vim

if test -f $HOME/.vimrc; then
    echo "$this: $HOME/.vimrc exits, renaming to $HOME/.vimrc.$$"
    mv $HOME/.vimrc $HOME/.vimrc.$$
fi 
cp vimrc $HOME/.vimrc

if test -f $HOME/.vimrc-ide; then
    echo "$this: $HOME/.vimrc-ide exits, renaming to $HOME/.vimrc-ide.$$"
    mv $HOME/.vimrc-ide $HOME/.vimrc-ide.$$
fi 
cp vimrc-ide $HOME/.vimrc-ide

# ------------
# my common ~/bin utilities
# ------------
echo $this: installing common utilities

if test -d $WD/../../utils; then
    cd $WD/../../utils
    make install_all
else
    echo "$this: unable to find common utilities project, skipping..."
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


