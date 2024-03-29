#
# mjeffe .bash_profile
#
# Reminder...
#
#  Bash will execute the ~/.profile for login shells. The ~/.bashrc is only
#  sourced for non-login, interactive shells, so be sure to source it somewhere
#  in your .profile.  See the INVOCATION chapter in the bash man page for details,
#  including file name precedence (~/.bash_profile vs ~/.profile), etc.
#

#export ORACLE_SID=CCTST
#ORAENV_ASK=NO . oraenv

# !!! Comment next line out if on multi-user system !!!
# having current directory in your path can be a security risk, even on a
# single user system. google it
#export PATH=$PATH:.
export PATH=$HOME/bin:$PATH
export LD_LIBRARY_PATH=$HOME/lib:$LD_LIBRARY_PATH

export EDITOR=vim
export VISUAL=vim

export CVS_RSH=ssh
export CVSEDITOR=vim

#export PS1='[\u@\h[$ORACLE_SID]:\w]$ '

# used by most acx and mrj Makefiles
export MAKE_MACHINE=LINUX

# # uncomment for server type machines
# #
# # start up ssh-agent - for use on non-GUI, server type machines.
# # Most modern Linux Desktop distros have something like this built
# # in, so you won't need this.
# #
# # This keeps ssh-agent running and in use by all login shells. You
# # will need to specifically source SSH_ENV from any cron jobs.  An
# # alternative is to use /usr/bin/keychain (install from rpmforge).
# # To use keychain, replace ssh-agent code with this:
# #   # Start Keychain
# #   /usr/bin/keychain ~/.ssh/id_rsa
# #   . ~/.keychain/${HOSTNAME}-sh > /dev/null
# #
# SSH_ENV="$HOME/.ssh/environment"
# function start_agent {
#    # starts an agent running, only if one is not already running
#    # that means it will stay running unless killed in .logout
#    echo "Initialising new SSH agent..."
#    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
#    echo succeeded
#    chmod 600 "${SSH_ENV}"
#    . "${SSH_ENV}" > /dev/null
#    /usr/bin/ssh-add;
# }
#
# # Source SSH settings, if applicable
#
# if [ -f "${SSH_ENV}" ]; then
#    . "${SSH_ENV}" > /dev/null
#    #ps ${SSH_AGENT_PID} doesn't work under cywgin
#    ps -ef | grep ${SSH_AGENT_PID} | grep 'ssh-agent$' > /dev/null || {
#       start_agent;
#    }
# else
#    start_agent;
# fi


