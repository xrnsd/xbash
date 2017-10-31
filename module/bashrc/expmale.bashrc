# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

#added by wgx
#=========================================================================
#====================== 自定义配置 =======================================
#=========================================================================

#----------------    函数实现   ----------------------------------
ftLnUtil()
{
    local ftEffect=获取软连接的真实路径
    local lnPath=$1

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftLnUtil 软连接路径
#    ftLnUtil /home/xian-hp-u16/log/xb_backup
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$lnPath" ];then    errorContent="${errorContent}\\n[软连接为空]lnPath=$lnPath" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftLnUtil -h
            return
    fi

    OLD_IFS="$IFS"
    IFS="/"
    arr=($lnPath)
    IFS="$OLD_IFS"

    i=${#arr[@]}
    let i--
    delDir=
    while [ $i -ge 0 ]
    do
        [[ $lnPath =~ ^/  ]] && lnRealPath=$lnPath || lnRealPath=`pwd`/$lnPath
        while [ -h $lnRealPath ]
        do
           b=`ls -ld $lnRealPath|awk '{print $NF}'`
           c=`ls -ld $lnRealPath|awk '{print $(NF-2)}'`
           [[ $b =~ ^/ ]] && lnRealPath=$b  || lnRealPath=`dirname $c`/$b
        done
        if [ "$lnRealPath" = "$lnPath" ];then
            lnPath=${lnPath%/*}
            delDir=${arr[$i]}/$delDir
        else
            echo ${lnRealPath}${delDir}
            break
        fi
        let i--
    done
}
#----------------    基础变量    ----------------------------------
userName=$(who am i | awk '{print $1}'|sort -u)
userName2=$(whoami | awk '{print $1}'|sort -u)
userName=${userName:-$userName2}
if [ "${S/ /}" != "$S" ];then
    userName=$(whoami) 
fi
export dirPathHome=/home/${userName}

# 根据.bashrc的软连接指向的文件路径截取出xbash根文件夹的名字[默认cmds]
filePathBashrc=~/.bashrc
if [[ -f  $filePathBashrc ]]; then
    filePathBashrcReal=$(ftLnUtil $filePathBashrc)
    if [[ "$filePathBashrcReal" != "${dirPathHome}/.bashrc " ]]; then
                filePathBashrcReal=$(echo $filePathBashrcReal | sed "s ${dirPathHome}/   ")
                OLD_IFS="$IFS"
                IFS="/"
                arrayItems=($filePathBashrcReal)
                IFS="$OLD_IFS"
                dirNameXbash=${arrayItems}
    fi
fi
export dirNameXbash=${dirNameXbash:-'cmds'}

export dirPathHomeCmd=${dirPathHome}/${dirNameXbash}
export dirPathHomeTools=${dirPathHome}/tools

#---------------- xbash配置  ----------------------------------
if [ ! -d "$dirPathHomeCmd" ];then
        echo -e "\033[1;31mXbash下实现的自定义命令不可用,找不到:[$dirPathHomeCmd]\033[0m"
else
        dirPathHomeCmdConfig=${dirPathHomeCmd}/config
        dirPathHomeCmdConfigBashrc=${dirPathHomeCmd}/config/bashrc

        fileNameXbashTragetBashrcConfigBase=config_bashrc_base
        filePathXbashTragetBashrcConfigBase=${dirPathHomeCmdConfigBashrc}/${fileNameXbashTragetBashrcConfigBase}

        fileNameXbashTragetBashrcConfigBaseGone=config_bashrc_base.gone
        filePathXbashTragetBashrcConfigBaseGone=${dirPathHomeCmdConfigBashrc}/${fileNameXbashTragetBashrcConfigBaseGone}

        fileNameXbashTragetBashrcConfigBaseGoneExample=config_bashrc_base.gone_simple
        filePathXbashTragetBashrcConfigBaseGoneExample=${dirPathHomeCmdConfigBashrc}/${fileNameXbashTragetBashrcConfigBaseGoneExample}
        #----------------   加载xbash的bashrc基础配置  ------------------
        if [ -f "$filePathXbashTragetBashrcConfigBaseGone" ];then
            source $filePathXbashTragetBashrcConfigBaseGone
        else
            echo -e "\033[1;31m找不到Xbash下实现的自定义命令需要的隐藏配置\n$filePathXbashTragetBashrcConfigBaseGone\033[0m"
            echo -e "\033[1;33m解决此问题可以参考模版\n$filePathXbashTragetBashrcConfigBaseGoneExample\033[0m"
        fi
        if [ -f "$filePathXbashTragetBashrcConfigBase" ];then
            source $filePathXbashTragetBashrcConfigBase
            #---------------------------------用户部分信息---------------------------------
            filePathUserConfig=${rDirPathCmdsConfig}/${userName}.config
            if [[ -f $filePathUserConfig ]]; then
                source $filePathUserConfig
            fi
        else
            echo -e "\033[1;31找不到mXbash下实现的自定义命令需要的配置\n$filePathXbashTragetBashrcConfigBase\033[0m"
        fi
fi
