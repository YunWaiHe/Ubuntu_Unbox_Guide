# 基本配置

## Config

```shell
# password
sudo su
sudo passwd
# package isntall
sudo apt install vim curl git htop cmake build-essential python3-dev python3-pip ninja-build
# disable wayland
sudo vim /etc/gdm3/custom.conf
# apt source
cat <<'EOF' | sudo tee /etc/apt/sources.list.d/ubuntu.sources
Types: deb
URIs: https://mirrors.cernet.edu.cn/ubuntu
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb deb-src
URIs: http://security.ubuntu.com/ubuntu/
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb deb-src
URIs: http://ftp.udx.icscoe.jp/Linux/ubuntu/
Suites: noble noble-updates noble-backports noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

# HWE Kernel
sudo apt install --install-recommends linux-generic-hwe-24.04 linux-tools-generic-hwe-24.04
# zerotier ipv6 disable
cat <<'EOF' | sudo tee /etc/sysctl.d/20-zerotierv6.conf
net.ipv6.conf.yourzerotiername.disable_ipv6 = 1
EOF
sudo deb-systemd-invoke restart procps.service
# locales setting
sudo dpkg-reconfigure locales
echo "zh_CN.UTF-8 UTF-8" | sudo tee /var/lib/locales/supported.d/zh-hans
echo "en_US.UTF-8 UTF-8" | sudo tee /var/lib/locales/supported.d/en
sudo locale-gen

# force english dir name if u choose Chinese while installing
# if needed, prepare the folder
ln -s /mnt/win_d_600G/Folder/Documents/ /home/user1/Documents
ln -s /mnt/win_d_600G/Folder/Music/ /home/user1/Music
ln -s /mnt/win_d_600G/Folder/Pictures/ /home/user1/Pictures
ln -s /mnt/win_d_600G/Folder/Videos/ /home/user1/Videos
LC_ALL=C xdg-user-dirs-update --force && sudo reboot
```

## apparmor (fixed)

<font color=red>FIXED, 无需配置</font>

解决包括但不限于微信没法用、桌面缩略图不显示等诸多问题

[https://bugs.launchpad.net/ubuntu/+source/nautilus/+bug/2047256](https://bugs.launchpad.net/ubuntu/+source/nautilus/+bug/2047256)

https://bugs.launchpad.net/ubuntu/+source/nautilus/+bug/2054183

```shell
echo "kernel.apparmor_restrict_unprivileged_userns=0" | sudo tee /etc/sysctl.d/30-apparmor.conf
sudo sysctl -p
sudo deb-systemd-invoke restart procps.service
```

## AppImages

AppImages包依赖

```shell
sudo apt install libfuse2t64
```

## Others

```shell
sudo dpkg-reconfigure tzdata
sudo dpkg-reconfigure ca-certificates
sudo dpkg-reconfigure console-setup
```



# VIM配置

## Vim Config

```shell
cat << "EOF" | sudo tee -a /etc/vim/vimrc
set tabstop=4
set softtabstop=4
set shiftwidth=4
"set expandtab
"set smarttab
set autoindent

call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'junegunn/seoul256.vim'
Plug 'vim-scripts/httplog'
Plug 'tpope/vim-sleuth'
Plug 'ycm-core/youcompleteme'
call plug#end()

let g:ycm_global_ycm_extra_conf = '/usr/share/vim/plugged/youcompleteme/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
let g:ycm_key_list_select_completion = ['<TAB>']
EOF

# main user
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cd ~/.vim/plugged/youcompleteme
./install.py --clang-completer --ninja --verbose
# root user
sudo su
cd
sudo curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cd ~/.vim/plugged/youcompleteme
./install.py --force-sudo --clang-completer --ninja --verbose
```



# 网络配置

## Network Config

```shell
sudo apt purge cloud-init
rm -r /etc/cloud/ && rm -rf /var/lib/cloud/
sudo rm /etc/netplan/50-cloud-init.yaml
sudo chmod 600 /etc/netplan/*.yaml
sudo netplan apply
sudo systemctl restart NetworkManager
```

## NTP

```shell
sudo mkdir /etc/systemd/timesyncd.conf.d
sudo touch /etc/systemd/timesyncd.conf.d/public_ntp.conf
cat << 'EOF' | sudo tee /etc/systemd/timesyncd.conf.d/public_ntp.conf
[Time]
NTP=ntp.ntsc.ac.cn
FallbackNTP=ntp6.aliyun.com
EOF
sudo systemctl restart systemd-timesyncd.service
sudo systemctl status systemd-timesyncd.service
```

## DNS

```shell
sudo sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved
resolvectl flush-caches
```

## APT代理配置

```shell
cat << 'EOF' | sudo tee /etc/apt/apt.conf.d/99proxy.conf
Acquire::http::Proxy "http://127.0.0.1:10809";
Acquire::https::Proxy "http://127.0.0.1:10809";
Acquire::http::Proxy {
    mirrors.zju.edu.cn "DIRECT";
}
Acquire::https::Proxy {
    developer.download.nvidia.cn "DIRECT";
}
EOF
```



# 磁盘

## NTFS Auto Mount

```shell
sudo apt install ntfs-3g
sudo fdisk -l # 确定要挂载的磁盘分区
sudo blkid # 查看分区对应UUID TYPE
id # 查看uid gid
sudo mkdir /mnt/win_d_600G
sudo mkdir /mnt/win_e_1D4T
# 之后在/etc/fstab 中新加下面这一行，按实际情况修改，UUID改为对应的，挂载点选择/mnt/dir_name，类型ntfs-3g便于设置权限，后面的options意思是用户可以挂载，win文件夹名称合法性检查，属于当前用户，文件夹755，文件644，不备份，在根文件系统之后检查
cat << 'EOF' | sudo tee -a /etc/fstab
# win10 D: E:
UUID=E892549DFD9D9562 /mnt/win_d_600G ntfs-3g user,exec,dev,suid,windows_names,uid=1000,gid=1000,dmask=0022,fmask=0133 0 2
UUID=4A71C1335FE7A391 /mnt/win_e_1D4T ntfs-3g user,exec,dev,suid,windows_names,uid=1000,gid=1000,dmask=0022,fmask=0133 0 2
# HDD
UUID=bc6d7035-eec7-45bc-af48-d8d927cddb26 /mnt/HDD3D6T ext4 defaults 0 2
EOF

sudo systemctl daemon-reload
sudo mount -a
```



# GNOME优化

## Theme and Tweaks

```shell
sudo apt install gnome-tweaks chrome-gnome-shell gnome-shell-extension-prefs gnome-shell-extension-manager
# manual install instead
# sudo apt install gdm-settings
# 扩展省略
git clone https://github.com/PRATAP-KUMAR/gdm-extension/
cd gdm-extension
sudo make install
```

gdm-settings 删除后残留问题，

```shell
# 删除local gschemas
sudo rm /usr/local/share/glib-2.0/schemas/gschemas.compiled
# 重新生成
sudo glib-compile-schemas /usr/share/glib-2.0/schemas
# 打开dconf-editor验证
```

可能的原因：dconf-editor读取时，存在优先级，而gdm-settings在local创建了gschemas，卸载gdm-settings时没有删除掉这项内容，导致donf-editor读取的旧的数据。

## Font

```shell
sudo apt install font-manager
sudo apt update && sudo apt install ttf-mscorefonts-installer

# 安装字体至系统范围
sudo cp *.ttf /usr/local/share/fonts/
sudo fc-cache -f -v # 重建字体缓存
```





# 终端配置

## Terminal

```shell
sudo apt install dconf-editor

# 示例配置
cat << 'EOF'| tee gnome_terminal_dracula_theme.txt
[/]
background-color='#282A36'
bold-color='#6E46A4'
bold-color-same-as-fg=true
bold-is-bright=true
custom-command='/usr/bin/zsh'
default-size-columns=96
foreground-color='#F8F8F2'
palette=['rgb(33,34,44)', 'rgb(255,85,85)', 'rgb(80,250,123)', 'rgb(241,250,140)', 'rgb(0,175,255)', 'rgb(255,121,198)', 'rgb(139,233,253)', 'rgb(248,248,242)', 'rgb(98,114,164)', 'rgb(255,110,110)', 'rgb(105,255,148)', 'rgb(255,255,165)', 'rgb(0,215,255)', 'rgb(255,146,223)', 'rgb(164,255,255)', 'rgb(255,255,255)']
use-custom-command=true
use-theme-colors=true
visible-name='Dracula'
EOF
# 新建配置，去dconf-editor复制路径7512993d-2577-4f9b-a035-2959d776c1dd
dconf load /org/gnome/terminal/legacy/profiles:/:7512993d-2577-4f9b-a035-2959d776c1dd/ < gnome_terminal_dracula_theme.txt
dconf write /org/gnome/terminal/legacy/profiles:/list "['b1dcc9dd-5262-4d8d-a863-c897e6d979b9','7512993d-2577-4f9b-a035-2959d776c1dd']"
# 完成后选中名为Dracula的配置文件

# 配置重置
dconf reset -f /org/gnome/terminal/
```

## ZSH & Oh-my-zsh

```shell
sudo apt install zsh

sudo echo 'alias proxy="export http_proxy=http://127.0.0.1:10809;export https_proxy=http://127.0.0.1:10809"' | sudo tee -a /etc/bash.bashrc
sudo echo 'alias unproxy="unset http_proxy;unset https_proxy"' | sudo tee -a /etc/bash.bashrc

sudo echo 'alias proxy="export http_proxy=http://127.0.0.1:10809;export https_proxy=http://127.0.0.1:10809"' | sudo tee -a /etc/zsh/zshrc
sudo echo 'alias unproxy="unset http_proxy;unset https_proxy"' | sudo tee -a /etc/zsh/zshrc

sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/chrissicool/zsh-256color ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-256color
git clone https://github.com/conda-incubator/conda-zsh-completion.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/conda-zsh-completion

# 'EOF'表示不进行转义
# 普通用户
cat << 'EOF' | tee $ZSH_CUSTOM/themes/my_maran.zsh-theme
PROMPT='%{$fg[cyan]%}%n%{%f%}@%{$fg[yellow]%}%M:%{$fg[magenta]%}%~ $(git_prompt_info)$(git_prompt_status)%{%f%u%}%(?,,%{$fg[red]%})$%(?,,%{%f%}) '
RPROMPT='%{$fg[blue]%}%*%{$fg[default]%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}-dirty%{$fg[blue]%}]%{%U%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}-clean%{$fg[blue]%}]"

ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[190]%}-untracked"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[082]%}}-added"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[166]%}-modified"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[220]%}-renamed"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[160]%}-deleted"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[082]%}-unmerged"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}-AHEAD"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}-BEHIND"
ZSH_THEME_GIT_PROMPT_DIVERGED="%{$fg_bold[red]%}--DIVERGED"
ZSH_THEME_GIT_PROMPT_STASHED="%{$fg_bold[blue]%}-STASHED"
EOF
# root用户
sudo su
cat << 'EOF' | tee $ZSH_CUSTOM/themes/my_maran.zsh-theme
PROMPT='%{$fg_bold[white]$bg[red]%}%n%{%f%k%}@%{$fg[blue]%}%M:%{$fg[magenta]%}%~ $(git_prompt_info)$(git_prompt_status)%{%f%u%}%(?,,%{$fg[red]%})#%(?,,%{%f%b%}) '
RPROMPT='%{$fg[cyan]%}%*%{$fg[default]%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}-dirty%{$fg[blue]%}]%{%U%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}-clean%{$fg[blue]%}]"

ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[190]%}-untracked"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[082]%}}-added"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[166]%}-modified"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[220]%}-renamed"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[160]%}-deleted"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[082]%}-unmerged"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}-AHEAD"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}-BEHIND"
ZSH_THEME_GIT_PROMPT_DIVERGED="%{$fg_bold[red]%}--DIVERGED"
ZSH_THEME_GIT_PROMPT_STASHED="%{$fg_bold[blue]%}-STASHED"
EOF
```

.zshrc

```shell
export PATH=$HOME/.local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="my_maran"

plugins=(git
sudo
history
colored-man-pages
command-not-found
virtualenvwrapper
zsh-256color
zsh-autosuggestions
zsh-syntax-highlighting
conda-zsh-completion
)

export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST
source $ZSH/oh-my-zsh.sh

alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'    
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias x11_as_root='sudo xauth add $(xauth list $DISPLAY)'

setopt nonomatch

# completion rehash
autoload -Uz compinit && compinit
zstyle ':completion:*' rehash true

# zsh history behavior
setopt BANG_HIST                # Treat the '!' character specially during expansion.
setopt INC_APPEND_HISTORY       # Write to the history file immediately, not when the shell exits.
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS         # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS     # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS        # Do not display a line previously found.
setopt HIST_IGNORE_SPACE        # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS        # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS       # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY              # Don't execute immediately upon history expansion.
unsetopt SHARE_HISTORY          # DO NOT Share history between all sessions.
unsetopt EXTENDED_HISTORY       # DO NOT Write the history file in the ":start:elapsed;command" format.
zshaddhistory() { 
  local cmd="${${(z)1}[1]}"
  if [[ "$cmd" == "sudo" ]]; then
    cmd="${${(z)1}[2]}"
  fi
  whence $cmd >| /dev/null || return 1
}

# Xshell key
bindkey '\e[1~' beginning-of-line   # Home
bindkey '\e[4~' end-of-line         # End
bindkey -s "^[Op" "0"   # 0
bindkey -s "^[Ol" "."   # .
bindkey -s "^[OM" "^M"  # Enter
bindkey -s "^[Oq" "1"   # 1
bindkey -s "^[Or" "2"   # 2
bindkey -s "^[Os" "3"   # 3
bindkey -s "^[Ot" "4"   # 4
bindkey -s "^[Ou" "5"   # 5
bindkey -s "^[Ov" "6"   # 6
bindkey -s "^[Ow" "7"   # 7
bindkey -s "^[Ox" "8"   # 8
bindkey -s "^[Oy" "9"   # 9
bindkey -s "^[Ok" "+"   # +
bindkey -s "^[Om" "-"   # -
bindkey -s "^[Oj" "*"   # *
bindkey -s "^[Oo" "/"   # /
```

Caution:

**For root, it's strongly recommended that record all commands to history for security audit.**

```shell
# History behavior
setopt BANG_HIST                # Treat the '!' character specially during expansion.
setopt INC_APPEND_HISTORY       # Write to the history file immediately, not when the shell exits.
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicate entries first when trimming history.
setopt HIST_FIND_NO_DUPS        # Do not display a line previously found.
setopt HIST_REDUCE_BLANKS       # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY              # Don't execute immediately upon history expansion.
# espically for root
setopt EXTENDED_HISTORY         # Write the history file in the ":start:elapsed;command" format.
unsetopt HIST_IGNORE_DUPS       # record an entry that was just recorded again.
unsetopt HIST_IGNORE_ALL_DUPS   # DO NOT Delete old recorded entry if new entry is a duplicate.
unsetopt HIST_IGNORE_SPACE      # record an entry starting with a space.
unsetopt HIST_SAVE_NO_DUPS      # write duplicate entries in the history file.
unsetopt SHARE_HISTORY          # DO NOT Share history between all sessions.
```







# 输入法

## Input Method

```shell
# remove unneed
sudo apt purge ibus* fcitx*
sudo apt autopurge
sudo rm -r ~/.cache/fcitx*
sudo rm -r ~/.config/fcitx*
sudo rm -r ~/.local/share/fcitx*
sudo rm -r ~/.cache/ibus*
sudo rm -r ~/.config/ibus*
sudo rm -r ~/.local/share/ibus*
sudo rm -r /root/.config/ibus
sudo rm -r /var/lib/gdm3/.config/ibus

sudo cat << 'EOF' | sudo tee /etc/environment.d/90fcitx.conf
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS="@im=fcitx"
EOF
sudo apt install fcitx libqt5qml5 libqt5quick5 libqt5quickwidgets5 qml-module-qtquick2 libgsettings-qt1
sudo cp /usr/share/applications/fcitx.desktop /etc/xdg/autostart/
```



# Snap 配置

## Snap App

```shell
# remove unused snap apps
sudo snap remove --purge firefox
sudo snap remove --purge thunderbird
sudo apt purge firefox* thunderbird*
# refresh or restore snap-store
sudo snap refresh snap-store --channel=latest/stable/ubuntu-24.04
# set retain count
sudo snap set system refresh.retain=2
#Removes old revisions of snaps
cd
cat << 'EOF' | tee clean_snap_old.sh
#!/bin/bash
#Removes old revisions of snaps
#CLOSE ALL SNAPS BEFORE RUNNING THIS
set -eu
LANG=en_US.UTF-8 snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        sudo snap remove "$snapname" --revision="$revision"
    done
EOF

chmod +x clean_snap_old.sh
sudo ./clean_snap_old.sh
# block snap package from apt
cat << 'EOF'| sudo tee /etc/apt/preferences.d/snap-apps-disable
Package: chromium* firefox* thunderbird*
Pin: version /.*snap.*/
Pin-Priority: -99
EOF
# validate block result
apt policy firefox chromium-browser thunderbird
```



# 其他软件

## remove

```shell
sudo apt purge transmission* gnome-snapshot* remmina* openvpn* sssd*
sudo apt autopurge
```



## Software Download and Installation

### chrome

```shell
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
```

### typora

```shell
wget -qO - https://typora.io/linux/public-key.asc | sudo tee /etc/apt/trusted.gpg.d/typora.asc
sudo add-apt-repository 'deb https://typora.io/linux ./'
sudo apt update
sudo apt install typora pandoc

# Dracula Theme
wget https://github.com/Teyler7/dracula-typora-theme/archive/refs/heads/main.zip && unzip main.zip && rm main.zip
cp -r dracula-typora-theme-main/theme/* ~/.config/Typora/themes/
# base.user.css config
cd ~/.config/Typora/themes
cat << 'EOF' | tee base.user.css
.CodeMirror-wrap .CodeMirror-code pre {
  font-family: "Ubuntu Sans Mono","Noto Sans CJK SC";
}

body {
  font-family: "Noto Sans CJK SC";
}

:root {
  --monospace: "Ubuntu Sans Mono","Noto Sans CJK SC";
}
EOF
# Dracula CodeMirror Config
{ cat - dracula.css > tempcss && mv tempcss dracula.css; } <<'EOF'
.cm-s-inner.CodeMirror, .cm-s-inner .CodeMirror-gutters {
  background-color: #282a36 !important;
  color: #f8f8f2 !important;
  border: none !important;
}
.cm-s-inner .CodeMirror-gutters { color: #282a36; }
/* .cm-s-inner .CodeMirror-cursor { border-left: solid thin #f8f8f0 !important; } */
.cm-s-inner .CodeMirror-cursor { border-left: 1.6px solid #ffffff !important; }
.cm-s-inner .CodeMirror-linenumber { color: #6D8A88 !important; }
.cm-s-inner .CodeMirror-selected { background: rgba(255, 255, 255, 0.10) !important; }
.cm-s-inner .CodeMirror-line::selection, .cm-s-inner .CodeMirror-line > span::selection, .cm-s-inner .CodeMirror-line > span > span::selection { background: rgba(255, 255, 255, 0.10) !important; }
.cm-s-inner .CodeMirror-line::-moz-selection, .cm-s-inner .CodeMirror-line > span::-moz-selection, .cm-s-inner .CodeMirror-line > span > span::-moz-selection { background: rgba(255, 255, 255, 0.10) !important; }
.cm-s-inner span.cm-comment { color: #FF79C6 !important; }
.cm-s-inner span.cm-string, .cm-s-inner span.cm-string-2 { color: #f1fa8c !important; }
.cm-s-inner span.cm-number { color: #bd93f9 !important; }
.cm-s-inner span.cm-variable { color: #50fa7b !important; }
.cm-s-inner span.cm-variable-2 { color: white !important; }
.cm-s-inner span.cm-def { color: #50fa7b !important; }
.cm-s-inner span.cm-operator { color: #ff79c6 !important; }
.cm-s-inner span.cm-keyword { color: #ff79c6 !important; }
.cm-s-inner span.cm-atom { color: #bd93f9 !important; }
.cm-s-inner span.cm-meta { color: #f8f8f2 !important; }
.cm-s-inner span.cm-tag { color: #ff79c6 !important; }
.cm-s-inner span.cm-attribute { color: #50fa7b !important; }
.cm-s-inner span.cm-qualifier { color: #50fa7b !important; }
.cm-s-inner span.cm-property { color: #66d9ef !important; }
.cm-s-inner span.cm-builtin { color: #50fa7b !important; }
.cm-s-inner span.cm-variable-3, .cm-s-inner span.cm-type { color: #ffb86c !important; }
.cm-s-inner .CodeMirror-activeline-background { background: rgba(255,255,255,0.1) !important; }
.cm-s-inner .CodeMirror-matchingbracket { text-decoration: underline; color: white !important; }

EOF
```

### zerotier

```shell
# 2024.05.03 supported
curl -s https://install.zerotier.com | sudo bash
```

### v2raya

```shell
# v2raya
wget -qO - https://apt.v2raya.org/key/public-key.asc | sudo tee /etc/apt/keyrings/v2raya.asc
git clone https://github.com/XTLS/Xray-install.git
cd Xray-install
sudo ./install-release.sh install
# if necessary
# replace with https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat

sudo ./install-release.sh install-geodata
sudo apt install v2raya
sudo systemctl disable xray
sudo systemctl enable v2raya
sudo systemctl start v2raya
```

### ubuntu cleaner

**2024.05.07 SUPPORTED**

```shell
sudo add-apt-repository ppa:gerardpuig/ppa
sudo apt update
sudo apt install ubuntu-cleaner
```

### BCompare

[https://gist.github.com/rise-worlds/5a5917780663aada8028f96b15057a67](https://gist.github.com/rise-worlds/5a5917780663aada8028f96b15057a67)

[https://gist.github.com/satish-setty/04e1058d3043f4d10e2d52feebe135e8](https://gist.github.com/satish-setty/04e1058d3043f4d10e2d52feebe135e8)

```shell
sudo rm -rf ~/.config/bcompare /root/.config/bcompare
sudo sed -i "s/keexjEP3t4Mue23hrnuPtY4TdcsqNiJL-5174TsUdLmJSIXKfG2NGPwBL6vnRPddT7tH29qpkneX63DO9ECSPE9rzY1zhThHERg8lHM9IBFT+rVuiY823aQJuqzxCKIE1bcDqM4wgW01FH6oCBP1G4ub01xmb4BGSUG6ZrjxWHJyNLyIlGvOhoY2HAYzEtzYGwxFZn2JZ66o4RONkXjX0DF9EzsdUef3UAS+JQ+fCYReLawdjEe6tXCv88GKaaPKWxCeaUL9PejICQgRQOLGOZtZQkLgAelrOtehxz5ANOOqCaJgy2mJLQVLM5SJ9Dli909c5ybvEhVmIC0dc9dWH+/N9KmiLVlKMU7RJqnE+WXEEPI1SgglmfmLc1yVH7dqBb9ehOoKG9UE+HAE1YvH1XX2XVGeEqYUY-Tsk7YBTz0WpSpoYyPgx6Iki5KLtQ5G-aKP9eysnkuOAkrvHU8bLbGtZteGwJarev03PhfCioJL4OSqsmQGEvDbHFEbNl1qJtdwEriR+VNZts9vNNLk7UGfeNwIiqpxjk4Mn09nmSd8FhM4ifvcaIbNCRoMPGl6KU12iseSe+w+1kFsLhX+OhQM8WXcWV10cGqBzQE9OqOLUcg9n0krrR3KrohstS9smTwEx9olyLYppvC0p5i7dAx2deWvM1ZxKNs0BvcXGukR+/g" /usr/lib/beyondcompare/BCompare
```

Enter License:

```
--- BEGIN LICENSE KEY ---
ayvZeJDYPBHS4J-1K6g6bDBuPoo0G-oGAq35blZtAoRqC-qQeSz28XAzX
6nTx9laTMLRCp6nAIhHNGZ2ehkeUfbnFaxEeLvI8fJavn-XQLNbOumCLU
qgdNbNMZiFRU03+OTQnw4V-E2YKTYi-LkgPzE6R-yIJGDNWfxH2AdpIgg
8rlpsbrTs9Dt1zysUfvAEi0dKbmGIi3rqf7yWmwDh1AI5VyoWFIejvJwJ
Lmlr2CjQ1VZ3DySCfBDuKcYmOCeK7jzEWPUnAw+f9360nIiiNEB0YGkwB
kdtgaKEEik7aNiI3jXvp5r34wViVJCiX7m2y7pqBV9gZIvP9hP9KPnP++++
--- END LICENSE KEY -----
```

```
--- BEGIN LICENSE KEY ---
GXN1eh9FbDiX1ACdd7XKMV7hL7x0ClBJLUJ-zFfKofjaj2yxE53xauIfkqZ8FoLpcZ0Ux6McTyNmODDSvSIHLYhg1QkTxjCeSCk6ARz0ABJcnUmd3dZYJNWFyJun14rmGByRnVPL49QH+Rs0kjRGKCB-cb8IT4Gf0Ue9WMQ1A6t31MO9jmjoYUeoUmbeAQSofvuK8GN1rLRv7WXfUJ0uyvYlGLqzq1ZoJAJDyo0Kdr4ThF-IXcv2cxVyWVW1SaMq8GFosDEGThnY7C-SgNXW30jqAOgiRjKKRX9RuNeDMFqgP2cuf0NMvyMrMScnM1ZyiAaJJtzbxqN5hZOMClUTE+++
--- END LICENSE KEY -----
```

### vscode

```shell
wget https://code.visualstudio.com/sha/download\?build\=stable\&os\=linux-deb-x64 --trust-server-names
```



### other

```shell
sudo apt install krdc gtkhash alacarte bleachbit flameshot pv pulseaudio pavucontrol unar progress needrestart iperf3
```

# NVIDIA

```shell
# After execute .run file , install mok
sudo mokutil --import /usr/share/nvidia/nvidia-modsign-crt-133DA1C2.der
```



使用显示器连接独显，出现未知的显示器。

https://bugs.launchpad.net/ubuntu/+source/linux/+bug/2060268

```shell
cat <<'EOF' |sudo tee -a /usr/lib/udev/rules.d/71-nvidia.rules
ACTION=="add", SUBSYSTEM=="module", KERNEL=="nvidia_drm", TEST=="/sys/devices/platform/simple-framebuffer.0/drm/card0", RUN+="/bin/rm /dev/dri/card0"
EOF
```



# Dev ToolChains

## llvm

```shell
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh <version number> # 17 or 18 is supported 2024.05.16
```

apt warns:

```shell
# modify /etc/apt/sources.list.d/archive_uri-http_apt_llvm_org_noble_-noble.list as bellow:
deb [arch=amd64] http://apt.llvm.org/noble/ llvm-toolchain-noble-18 main
deb-src [arch=amd64] http://apt.llvm.org/noble/ llvm-toolchain-noble-18 main
```

## cmake

~~**APT SOURCE 2024.05.16 NOT SUPPORTED**~~

2024.08.05 https://apt.kitware.com/ supported

TL;DR

```shell
test -f /usr/share/doc/kitware-archive-keyring/copyright ||
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null

echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ noble main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null

sudo apt-get update

sudo apt-get install kitware-archive-keyring
```

**Binary file is OK**

# dbg-sym

2024.08.05
Package from noble-security suite can not be found here but at launchpad.

Someone has found this question but no response.

https://bugs.launchpad.net/ubuntu/+source/openssh/+bug/2075996

As described in Ubuntu doc, it's recommend to not use ddebs but debuginfod.

https://ubuntu.com/server/docs/about-debuginfod

debuginfod also use indexes from ddebs.ubuntu.com.

```shell
sudo apt install ubuntu-dbgsym-keyring

cat << 'EOF' | sudo tee -a /etc/apt/sources.list.d/ddebs.list
deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse
deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse
EOF

```



