#!/bin/sh
#
# $Id$
#

JAMESTOOLS=/home/mjeffe/src/acx/sawmill/jamestools


WD=`pwd`
this=`basename $0`

# check to make sure jamestools has been checked out before trying to run
if test ! -d $JAMESTOOLS; then
   echo "$this: It looks like jamestools has not been checked out..."
   echo "use this command to check it out before running this again:"
   echo
   #echo "cd ~/src; cvs -d acxcvs.corp.acxiom.net:/cvsroot/sawmill co jamestools"
   echo "cd ~/src; svn checkout https://acxsvn.corp.acxiom.net/svn/sawmill/trunk/jamestools jamestools"
   echo
   exit 1
fi

if test $MAKE_MACHINE"x" = "x"; then
   echo "MAKE_MACHINE is not set."
   exit 1
fi

# install profile 
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
   
echo $this: installing custom vim stuff
cd $WD/../vim
make install

echo $this: installing common utilities
cd $WD/../utils
make install_all


(cd $JAMESTOOLS && ./install_essentials_locally.sh)

exit
# everything from here down has been incorporated into the utils Makefile

echo $this: compiling and installing dtof
cd $WD/../dtof
make
make install

echo $this: compiling and installing rrobin
cd $WD/../rrobin
make
make install

echo $this: installing essential jamestools

cd $WD/../../jamestools/ftod
make
cp ftod $HOME/bin


