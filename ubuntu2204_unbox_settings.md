# 配置

## APT源

```shell
deb http://repo.xxx.com/ubuntu/ jammy main restricted universe multiverse
deb-src http://repo.xxx.com/ubuntu/ jammy main restricted universe multiverse
deb http://repo.xxx.com/ubuntu/ jammy-updates main restricted universe multiverse
deb-src http://repo.xxx.com/ubuntu/ jammy-updates main restricted universe multiverse
deb http://repo.xxx.com/ubuntu/ jammy-backports main restricted universe multiverse
deb-src http://repo.xxx.com/ubuntu/ jammy-backports main restricted universe multiverse
deb http://repo.xxx.com/ubuntu/ jammy-security main restricted universe multiverse
deb-src http://repo.xxx.com/ubuntu/ jammy-security main restricted universe multiverse

# 校园网用户
deb http://mirrors.cernet.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb-src http://mirrors.cernet.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb http://mirrors.cernet.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb-src http://mirrors.cernet.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb http://mirrors.cernet.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb-src http://mirrors.cernet.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb http://mirrors.cernet.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
deb-src http://mirrors.cernet.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
```

## linux内核

```shell
# https://wiki.ubuntu.com/Kernel/LTSEnablementStack

# install HWE kernel
sudo apt install --install-recommends linux-generic-hwe-22.04 linux-tools-generic-hwe-22.04

# To downgrade from HWE/OEM to GA kernel:
sudo apt install --install-recommends linux-generic linux-tools-generic

# TODO uninstall method
```

## Ubuntu Pro

```
# 注册账号,按照说明操作
https://ubuntu.com/pro/
```

## ==NTFS磁盘自动挂载==

```shell
sudo apt install ntfs-3g
sudo fdisk -l # 确定要挂载的磁盘分区
blkid # 查看分区对应UUID TYPE
id # 查看uid gid

# 之后在/etc/fstab 中新加下面这一行，按实际情况修改，UUID改为对应的，挂载点选择/mnt/dir_name，类型ntfs-3g便于设置权限，后面的options意思是用户可以挂载，win文件夹名称合法性检查，属于当前用户，文件夹755，文件644，不备份，在根文件系统之后检查
UUID=E892549DFD9D9562   /mnt/win_d_600G     ntfs-3g     user,windows_names,uid=1000,gid=1000,dmask=0022,fmask=0033      0       2
```



## gnome-tweaks

调整缩放、字体等等，安装完成后软件名为“优化”

```shell
sudo apt install gnome-tweaks
```
## gnome-shell-extension

```shell
sudo apt install chrome-gnome-shell gnome-shell-extension-prefs

# extension suggestion
# https://extensions.gnome.org/extension/1634/resource-monitor/
# https://extensions.gnome.org/extension/615/appindicator-support/
# https://extensions.gnome.org/extension/779/clipboard-indicator/
# https://extensions.gnome.org/extension/906/sound-output-device-chooser/
# https://extensions.gnome.org/extension/19/user-themes/

# https://extensions.gnome.org/extension/1082/cpufreq/
# https://extensions.gnome.org/extension/7/removable-drive-menu/

# https://extensions.gnome.org/extension/1064/system-monitor/
sudo apt install gir1.2-gtop-2.0 libgtop2-dev
```

## 多音频设备

https://itsfoss.com/sound-switcher-indicator-ubuntu/

## AppImage

```shell
sudo apt install libfuse2
```



## 登录界面背景图片

```shell
wget -q https://raw.githubusercontent.com/PRATAP-KUMAR/ubuntu-gdm-set-background/main/ubuntu-gdm-set-background && chmod +x ubuntu-gdm-set-background

./ubuntu-gdm-set-background --help
# picture suggestion
wget https://512pixels.net/downloads/macos-wallpapers-6k/12-Dark.jpg
sudo cp 12-Dark.jpg /usr/share/backgrounds/
sudo chmod 644 /usr/share/backgrounds/12-Dark.jpg

wget https://512pixels.net/downloads/macos-wallpapers-6k/12-Light.jpg
sudo cp 12-Light.jpg /usr/share/backgrounds/
sudo chmod 644 /usr/share/backgrounds/12-Light.jpg

sudo ./ubuntu-gdm-set-background --image /usr/share/backgrounds/12-Light.jpg
# press ctrl+alt+f1 to check 
```


## 字体管理

```shell
sudo apt install font-manager
sudo apt update && sudo apt install ttf-mscorefonts-installer
# 安装字体至系统范围
sudo cp *.ttf /usr/local/share/fonts/
sudo fc-cache -f -v # 重建字体缓存
```


## 移除netplan

```shell
sudo systemctl disable --now systemd-networkd.service systemd-networkd.socket networkd-dispatcher.service && sudo systemctl restart NetworkManager 	        
sudo cp /usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf  /usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf_orig

cat << 'EOF' | sudo tee /usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf
[keyfile]
unmanaged-devices=*,except:type:wifi,except:type:gsm,except:type:cdma
EOF

sudo apt purge netplan netplan.io -y
sudo systemctl restart NetworkManager
```

## 恢复netplan

TODO

## snap

```shell
# remove firefox
snap remove --purge firefox
```

移除snap https://itsfoss.com/remove-snap/

```shell
sudo systemctl stop snapd.service
sudo systemctl stop snapd.socket
sudo systemctl stop snapd.apparmor.service
sudo systemctl stop snapd.mounts-pre.target
sudo systemctl stop snapd.mounts.target

snap remove --purge firefox
snap remove --purge gtk-common-themes
snap remove --purge gnome-3-38-2004
snap remove --purge gnome-42-2204
snap remove --purge snapd-desktop-integration
snap remove --purge snap-store
snap remove --purge core20
snap remove --purge core22
snap remove --purge bare
snap remove --purge snapd

sudo apt purge snapd
sudo apt-mark hold snapd

cat << 'EOF' | sudo tee /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

rm -rf ~/snap
sudo rm -rf /snap
sudo rm -rf /root/snap
sudo rm -rf /var/snap
sudo rm -rf /var/lib/snapd
sudo rm -rf /var/lib/gdm3/snap
sudo rm -r /sys/fs/bpf/snap

```

## 关闭53端口监听

```shell
sudo sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved
resolvectl flush-caches
```

## NTP时间同步

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

## 关闭MOTD(message of today)

```shell
sudo rm /etc/default/motd-news
sudo rm /etc/update-motd.d/50-motd-news
sudo systemctl stop motd-news.timer
sudo systemctl stop motd-news.service
sudo systemctl mask motd-news.service
sudo systemctl disable motd-news.timer
sudo systemctl mask motd-news.timer
```

## zh_SG问题

```shell
vim /etc/locale.gen 注释相关行
echo "zh_CN.UTF-8 UTF-8" | sudo tee /var/lib/locales/supported.d/zh-hans
echo "en_US.UTF-8 UTF-8" | sudo tee /var/lib/locales/supported.d/en
sudo locale-gen
```

## 文件夹名称（文档、图片、下载...）

```shell
LC_ALL=C xdg-user-dirs-update --force
# 强制英文文件夹名称，重启生效
```

## zsh配置

```shell
sudo apt install zsh
```

oh-my-zsh安装

```shell
sudo echo 'alias proxy="export http_proxy=http://127.0.0.1:10809;export https_proxy=http://127.0.0.1:10809"' | sudo tee -a /etc/bash.bashrc
sudo echo 'alias unproxy="unset http_proxy;unset https_proxy"' | sudo tee -a /etc/bash.bashrc

sudo echo 'alias proxy="export http_proxy=http://127.0.0.1:10809;export https_proxy=http://127.0.0.1:10809"' | sudo tee -a /etc/zsh/zshrc
sudo echo 'alias unproxy="unset http_proxy;unset https_proxy"' | sudo tee -a /etc/zsh/zshrc

sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/chrissicool/zsh-256color ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-256color
git clone https://github.com/conda-incubator/conda-zsh-completion.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/conda-zsh-completion
```

.zshrc配置

```shell
# 未列出的按需配置
plugins=(git
pip
sudo
colored-man-pages
command-not-found
virtualenvwrapper
zsh-256color
zsh-autosuggestions
zsh-syntax-highlighting
)

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

# XShell Key
# Home
bindkey '\e[1~' beginning-of-line
# End
bindkey '\e[4~' end-of-line

# Keypad
# 0 . Enter
bindkey -s "^[Op" "0"
bindkey -s "^[Ol" "."
bindkey -s "^[OM" "^M"
# 1 2 3
bindkey -s "^[Oq" "1"
bindkey -s "^[Or" "2"
bindkey -s "^[Os" "3"
# 4 5 6
bindkey -s "^[Ot" "4"
bindkey -s "^[Ou" "5"
bindkey -s "^[Ov" "6"
# 7 8 9
bindkey -s "^[Ow" "7"
bindkey -s "^[Ox" "8"
bindkey -s "^[Oy" "9"
# + -  * /
bindkey -s "^[Ok" "+"
bindkey -s "^[Om" "-"
bindkey -s "^[Oj" "*"
bindkey -s "^[Oo" "/"

```

最后执行```sed -i -e "/source \$ZSH\/oh-my-zsh.sh/i export ZSH_COMPDUMP=\$ZSH\/cache\/.zcompdump-\$HOST" ~/.zshrc```

主题

```shell
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

## Gnome-Terminal配置备份

```shell
# 导出配置
dconf dump /org/gnome/terminal/ > gnome_terminal_settings_backup.txt
# 重置
dconf reset -f /org/gnome/terminal/
# 加载备份的设置
dconf load /org/gnome/terminal/ < gnome_terminal_settings_backup.txt
# 完成后取消勾选"使用系统主体中的颜色"

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
# 新建配置，去dconf-editor
dconf load /org/gnome/terminal/legacy/profiles:/:7512993d-2577-4f9b-a035-2959d776c1dd/ < gnome_terminal_dracula_theme.txt

dconf write /org/gnome/terminal/legacy/profiles:/list "['b1dcc9dd-5262-4d8d-a863-c897e6d979b9','7512993d-2577-4f9b-a035-2959d776c1dd']"

# 完成后选中名为Dracula的配置文件
```



## VIM配置

```shell
echo "set tabstop=4" | sudo tee -a /etc/vim/vimrc
echo "set softtabstop=4" | sudo tee -a /etc/vim/vimrc
echo "set shiftwidth=4" | sudo tee -a /etc/vim/vimrc
echo "set expandtab" | sudo tee -a /etc/vim/vimrc
```

## Zerotier

```shell
# 关闭ipv6
sudo nmcli c show ztoname
sudo nmcli c modify ztoname ipv6.method disabled
sudo nmcli c up ztoname
sudo systemctl restart NetworkManager
```

## 无用软件移除( ==! 慎重 !== )

```shell
# pptp vpn
sudo apt purge network-manager-pptp network-manager-openvpn usb-creator-* transmission* thunderbird*  simple-scan gnome-mahjongg gnome-sudoku* aisleriot*
```

# 日用软件安装

## Typora

```shell
# add key
wget -qO - https://typoraio.cn/linux/public-key.asc | sudo tee /etc/apt/trusted.gpg.d/typora.asc

# add Typora's repository
sudo add-apt-repository 'deb https://typoraio.cn/linux ./'
sudo apt-get update

# install typora
sudo apt-get install typora pandoc
```

配置```~/.config/Typora/themes/base.user.css```

```css
.CodeMirror-wrap .CodeMirror-code pre {
  font-family: "Ubuntu Mono","Noto Sans CJK SC";
}

body {
  font-family: "Noto Sans CJK SC";
}

:root {
  --monospace: "Ubuntu Mono","Noto Sans CJK SC";
}
```

## Sogou Pinyin

```shell
sudo cat << 'EOF' | sudo tee /etc/environment.d/90sogou.conf
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS="@im=fcitx"
EOF

sudo apt install fcitx libqt5qml5 libqt5quick5 libqt5quickwidgets5 qml-module-qtquick2 libgsettings-qt1
sudo apt purge ibus*
sudo cp /usr/share/applications/fcitx.desktop /etc/xdg/autostart/
sudo dpkg -i debfilename
sudo reboot
# 进入系统后，打开终端，按下ctrl+space，看搜狗输入法的输入栏是否出现，若没有出现，打开“fcitx 配置”，将搜狗输入法移至最上，重启再次观察
```

## Ubuntu-Cleaner

```shell
sudo add-apt-repository ppa:gerardpuig/ppa
sudo apt update
sudo apt install ubuntu-cleaner
```

## 截图软件Flameshot

```shell
# Compile-time
sudo apt install g++ cmake build-essential qtbase5-dev qttools5-dev-tools libqt5svg5-dev qttools5-dev
# Run-time
sudo apt install libqt5dbus5 libqt5network5 libqt5core5a libqt5widgets5 libqt5gui5 libqt5svg5
# Optional
sudo apt install git openssl ca-certificates

sudo dpkg -i debfilename
```

https://github.com/flameshot-org/flameshot

## Iris 护眼软件

```shell
下载地址 https://iristech.co/download-linux-x64
# 下载、解压、移动至/opt,终端运行，补全缺失lib
# 修改桌面图标配置 ~/.local/share/applications/Iris.desktop 如下
[Desktop Entry]
Type=Application
Terminal=false
Name=Iris
Exec=/opt/Iris-0.9.9/Iris.sh
Icon=Iris
Terminal=false
Categories=Application;

# 缩放问题，界面过大
sed -i 's/UiScale=[0-9]\+/UiScale=1/' ~/.config/IrisTech/Iris.conf
```

激活方法：将激活所发送的网络请求转发至本地nginx处理，返回成功激活的响应。缺点是占用一定的空间，无法访问官网。

```shell
# 安装nginx,更改hosts文件，将iristech.co映射到127.0.0.1
sudo apt install nginx
echo "127.0.0.1 iristech.co" | sudo tee -a /etc/hosts
# nginx配置文件/etc/nginx/sites-available/IrisActivate如下：
sudo cat <<EOF | sudo tee /etc/nginx/sites-available/IrisActivate
server {
    listen 127.0.0.1:80;
    server_name iristech.co;

    location /custom-code/iris_license.php {
        default_type "text/html; charset=UTF-8";
        return 200 "SUCCESS";
        add_header Vary User-Agent;
        add_header Referrer-Policy no-referrer-when-downgrade;
        add_header Access-Control-Allow-Origin *;
        add_header X-SH-Cache-Status Excluded;
        keepalive_timeout 5;
    }
}
EOF
```

```shell
sudo ln -s  /etc/nginx/sites-available/IrisActivate /etc/nginx/sites-enabled/IrisActivate
sudo nginx -s reload
# 激活码框中输入任意英文或数字即可激活
```

## Beyond Compare

```shell
# https://www.scootersoftware.com/download
sudo dpkg -i debfilepath
# 激活
sudo sed -i "s/keexjEP3t4Mue23hrnuPtY4TdcsqNiJL-5174TsUdLmJSIXKfG2NGPwBL6vnRPddT7tH29qpkneX63DO9ECSPE9rzY1zhThHERg8lHM9IBFT+rVuiY823aQJuqzxCKIE1bcDqM4wgW01FH6oCBP1G4ub01xmb4BGSUG6ZrjxWHJyNLyIlGvOhoY2HAYzEtzYGwxFZn2JZ66o4RONkXjX0DF9EzsdUef3UAS+JQ+fCYReLawdjEe6tXCv88GKaaPKWxCeaUL9PejICQgRQOLGOZtZQkLgAelrOtehxz5ANOOqCaJgy2mJLQVLM5SJ9Dli909c5ybvEhVmIC0dc9dWH+/N9KmiLVlKMU7RJqnE+WXEEPI1SgglmfmLc1yVH7dqBb9ehOoKG9UE+HAE1YvH1XX2XVGeEqYUY-Tsk7YBTz0WpSpoYyPgx6Iki5KLtQ5G-aKP9eysnkuOAkrvHU8bLbGtZteGwJarev03PhfCioJL4OSqsmQGEvDbHFEbNl1qJtdwEriR+VNZts9vNNLk7UGfeNwIiqpxjk4Mn09nmSd8FhM4ifvcaIbNCRoMPGl6KU12iseSe+w+1kFsLhX+OhQM8WXcWV10cGqBzQE9OqOLUcg9n0krrR3KrohstS9smTwEx9olyLYppvC0p5i7dAx2deWvM1ZxKNs0BvcXGukR+/g" /usr/lib/beyondcompare/BCompare
```

打开软件：输入激活码

```
--- BEGIN LICENSE KEY ---
V6NdRrZdC3ncHYyiTGGGO-lBM7Qx7NNVNTYmijllfsTWANz9ZggPP5XflrSIsT0DOgEGX9P-czWpBh55O06k3KXPtPAP7po5S2+U3GaRawwFmmBbqItEc2JS95UBEV4nF5xuiL-sowb2gbk8jvC6csifW3q8K00w6-68kF0hfWc6IYW0he0bXw7KKNZRaVy5kqWjiDy97S3Vg876DGAbIh8hJr4EkYxGrOIhm+31OKNqqwoOcloGy1qH+iK6BtL2k6YYWQAbQ6InQE9UrtypGgV1kah1vlxMgWx7T+4U-Tw55U2KgZTkDfCz+9xoQaO9N4BsrNjHZmGbbTbzMkWMJ+++
--- END LICENSE KEY -----
```

## virtualbox

```shell
sudo cat <<EOF | sudo tee /etc/apt/sources.list.d/virtualbox.list
deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian jammy contrib
EOF
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg --dearmor

sudo apt install virtualbox-7.0
```

## 其他软件

```shell
# 图标管理，可以添加图标
sudo apt install alacarte
# 磁盘占用情况分析
sudo apt install baobab
# 文件hash
sudo apt install nautilus-gtkhash
# 远程
sudo apt install krdc breeze-icon-theme
sudo apt install gnome-connections
```

## AGH(Adguard Home)

```shell
# 安装

# DNS解析是否污染
ping raw.githubusercontent.com
# 如果解析结果被污染为127.0.0.1，更换DNS地址（取消勾选自动DNS,填入223.5.5.5,114.114.114.114,8.8.8.8）
# 刷新解析
sudo systemctl restart systemd-resolved.service

# 加快下载速度
export https_proxy=http://192.168.3.2:10809
wget --no-verbose -O - https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v

# 安装完成按教程设置即可

```
附上上游DNS的配置
```
# ++++++++++++++++++++++++++++++ 指定域名DNS ++++++++++++++++++++++++++++++
[/huaweicloud.com/v2raya.org/ubuntu.com/]运营商dns比较快
[/aaaa.gay/dl.google.com/]8.8.8.8
[/github.com/githubusercontent.com/]223.5.5.5
[/github.com/githubusercontent.com/]119.29.29.29
[/github.com/githubusercontent.com/]114.114.115.119
[/ip-api.com/openssl.org/googlesource.com/google.com/googleapis.com/]https://1.0.0.1/dns-query
# ++++++++++++++++++++++++++++++++ 通用DNS ++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++ DoH  ++++++++++++++++++++++++
#https://1.0.0.2/dns-query
#https://1.0.0.3/dns-query
#tcp://1.0.0.3
# +++++++++++++++++++++++ IPv4 ++++++++++++++++++++++++
114.114.115.119
#114.114.114.119
#114.114.115.115

#123.125.81.6
#117.50.11.11
#52.80.66.66
#https://doh.familyshield.opendns.com/dns-query
# 阿里DNS
223.5.5.5
#223.6.6.6
#2400:3200::1
#2400:3200:baba::1
#https://223.5.5.5/dns-query
# 腾讯DNS
#https://sm2.doh.pub/dns-query
#https://dns.ipv6dns.com/dns-query
#114.114.114.114
#114.114.115.115
#4.2.2.1
#4.2.2.2
#8.8.8.8
#8.8.4.4
```

## EasyConnect

```shell
chmod +x install_EasyConnect_Ubuntu22.04_x64.sh
./install_EasyConnect_Ubuntu22.04_x64.sh
# 显示用户协议提示勾选即为安装成功
# 若显示版本过高，尝试将install_EasyConnect_Ubuntu22.04_x64.sh中下载链接改为https://download.sangfor.com.cn/download/product/sslvpn/pkg/linux_01/EasyConnect_x64.deb
```

## v2raya(代理)

### 安装

```shell
cd ~/projects
git clone https://github.com/v2fly/fhs-install-v2ray.git
cd fhs-install-v2ray
cp install-dat-release.sh install-Loyalsoldier-dat-release.sh
chmod +x *.sh
# 安装v2ray-core
# 替换http://192.168.3.2:10809为自己的代理
sudo ./install-release.sh -p http://192.168.3.2:10809 > install.log

# 替换加强规则
sed -i 's#https://github.com/v2fly/geoip/releases/latest/download/geoip.dat#https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat#g' install-Loyalsoldier-dat-release.sh

sed -i 's#https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat#https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat#g' install-Loyalsoldier-dat-release.sh

sed -i 's/dlc.dat/geosite.dat/g' install-Loyalsoldier-dat-release.sh

# dat文件下载脚本只能手动配置代理
sed -i '/dir_tmp="$(mktemp -d)"/a\\nexport http_proxy=http://127.0.0.1:10809\nexport https_proxy=http://127.0.0.1:10809\n' install-Loyalsoldier-dat-release.sh
# 更新dat文件
sudo ./install-Loyalsoldier-dat-release.sh
sudo systemctl disable v2ray.service

# 安装xray-core  vless reality
cd ~/projects
wget https://github.com/XTLS/Xray-install/raw/main/install-release.sh
mv install-release.sh install-xtls-release.sh
sed -i 's#https://github.com/v2fly/geoip/releases/latest/download/geoip.dat#https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat#g' install-xtls-release.sh
sed -i 's#https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat#https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat#g' install-xtls-release.sh
sed -i 's/dlc.dat/geosite.dat/g' install-xtls-release.sh

sudo chmod +x install-xtls-release.sh
sudo ./install-xtls-release.sh install -u root > xtls-install.log
sudo ./install-xtls-release.sh install-geodata
sudo systemctl disable xray.service

# 安装v2raya
wget -qO - https://apt.v2raya.org/key/public-key.asc | sudo tee /etc/apt/trusted.gpg.d/v2raya.asc
echo "deb https://apt.v2raya.org/ v2raya main" | sudo tee /etc/apt/sources.list.d/v2raya.list
sudo apt update
sudo apt install v2raya
```

### routingA规则（路由规则）

官方教程 https://v2raya.org/docs/manual/routinga/

```shell
# 默认走代理
default: proxy
# 屏蔽运营商反诈
ip(182.43.124.6, 39.102.194.85, 101.35.177.86) -> block
# BT下载直连
protocol(bittorrent) -> direct
# 私有地址直连
ip(geoip:private) -> direct
# dns走代理
ip(1.1.1.1/8, 8.8.8.8/8) -> proxy

# 域名直连1 direct
## 手动设定的规则
domain(domain:qq.com) -> direct
domain(geosite:github, domain:deepl.com, domain:pendo.io, domain:recaptcha.net) -> proxy

# 屏蔽域名
# 域名屏蔽要放在相应ip规则之前
# 例如 屏蔽 uczzd.cn
# domain(domain:uczzd.cn) -> block
# 要放在ip(geoip:cn) -> direct之前，否则屏蔽规则失效

# 域名屏蔽豁免 direct or proxy


# 域名屏蔽 block
domain(geosite:category-ads-all, geosite:win-spy, geosite:category-porn) -> block
# 域名直连2 direct
## 别人整理好的规则
domain(geosite:cn, geosite:private, geosite:category-scholar-cn) -> direct
# 域名代理 proxy
domain(geosite:google-scholar, geosite:category-scholar-!cn) -> proxy
domain(geosite:gfw, geosite:geolocation-!cn, geosite:google) -> proxy
# ip直连
ip(geoip:cn) -> direct
# ip代理
ip(geoip:google, geoip:hk) -> proxy
```

geosite中可用规则 https://github.com/v2fly/domain-list-community/tree/master/data
加强版规则https://github.com/Loyalsoldier/v2ray-rules-dat

### 防止DNS劫持与污染

如果没有AGH可以配置，DNS查询走代理需要确认proxy提供商是否屏蔽DNS请求

# 单版本CUDA

11.8 https://docs.nvidia.com/cuda/archive/11.8.0/cuda-installation-guide-linux/index.html#ubuntu-installation

==step1==

```shell
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
# 中国CDN加速
sudo sed -i 's/nvidia.com/nvidia.cn/' /etc/apt/sources.list.d/cuda-ubuntu2204-x86_64.list
```

==step2==

*表示通配符

cuda 11.8

```shell
# 固定版本，以及禁止从ubuntu源安装cuda。
sudo cat <<EOF | sudo tee /etc/apt/preferences.d/cuda-pin
# disable nvidia software from huaweiorigin
Package: nsight-* nvidia-* libnvidia-* xserver-xorg-video-nvidia*
Pin: origin *huaweicloud.com*
Pin-Priority: -1

Package: nsight-* nvidia-* libnvidia-* xserver-xorg-video-nvidia*
Pin: origin *ubuntu.com*
Pin-Priority: -1

Package: nsight-* nvidia-* libnvidia-* xserver-xorg-video-nvidia*
Pin: origin *edu.cn*
Pin-Priority: -1

# set label:NVIDIA CUDA with high priority
Package: *
Pin: release l=NVIDIA CUDA
Pin-Priority: 600

# pin cuda's version to 11.8.*
Package: cuda cuda-toolkit-config-common
Pin: version 11.8.*
Pin-Priority: 1001

# pin cuda driver version
Package: cuda-drivers nvidia-settings nvidia-modprobe libxnvctrl0
Pin: version 535.*
Pin-Priority: 1001

# pin cudnn's version
Package: libcudnn8*
Pin: version *+cuda11.8
Pin-Priority: 1001

# pin tensorrt's version to cuda11.8
Package: tensorrt* libnvinfer* libnvonnxparsers* libnvparsers* onnx-graphsurgeon python3-libnvinfer* uff-converter-tf graphsurgeon-tf
Pin: version 8.*+cuda11.8
Pin-Priority: 1001

EOF
```

cuda 12.1

```shell
# 固定版本，以及禁止从ubuntu源安装cuda。
sudo cat <<EOF | sudo tee /etc/apt/preferences.d/cuda-pin
# disable nvidia software from huaweiorigin
Package: nsight-* nvidia-* libnvidia-* xserver-xorg-video-nvidia*
Pin: origin *huaweicloud.com*
Pin-Priority: -1

Package: nsight-* nvidia-* libnvidia-* xserver-xorg-video-nvidia*
Pin: origin *ubuntu.com*
Pin-Priority: -1

Package: nsight-* nvidia-* libnvidia-* xserver-xorg-video-nvidia*
Pin: origin *edu.cn*
Pin-Priority: -1

# set label:NVIDIA CUDA with high priority
Package: *
Pin: release l=NVIDIA CUDA
Pin-Priority: 600

# pin cuda's version to 12.1.*
Package: cuda cuda-toolkit-config-common
Pin: version 12.1.*
Pin-Priority: 1001

# pin cuda driver version to 535
Package: cuda-drivers nvidia-settings nvidia-modprobe libxnvctrl0
Pin: version 535.*
Pin-Priority: 1001

# pin cudnn's version to cuda12.1
Package: libcudnn8*
Pin: version *+cuda12.1
Pin-Priority: 1001

# pin tensorrt's version 8 cuda12.0
Package: libnvinfer-dispatch8 libnvinfer-lean8 libnvinfer-plugin8 libnvinfer-vc-plugin8 libnvinfer8 libnvonnxparsers8
Pin: version 8.*+cuda12.0
Pin-Priority: 1002

Package: tensorrt* libnvinfer* libnvonnxparsers* libnvparsers* onnx-graphsurgeon python3-libnvinfer* uff-converter-tf graphsurgeon-tf
Pin: version 8.*+cuda12.0
Pin-Priority: 1001

EOF
```

==step3==

```shell
# 进入纯命令行模式
sudo init 3
# 更改语言，防止小方块
export LANG=C
export LANGUAGE=C
sudo apt update
sudo apt install libcanberra-gtk-module cuda libcudnn8* tensorrt* onnx-graphsurgeon uff-converter-tf graphsurgeon-tf
```

==step4==

安装驱动时有弹窗提示，==记住输入的密码==，安装完成后重启。
屏幕提示选择```Enroll MOK```，输入密码。(更新bios后会丢失key，需重新安装驱动)
==step5==

```nvidia-smi```测试驱动是否安装成功，

Failed to initialize NVML: Insufficient Permissions 解决办法
```shell
sudo usermod -a -G  $(ls -l /dev/nvidia0 | awk '{print $4}') $(whoami)
```

## cuDNN

https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#package-manager-ubuntu-install

```shell
# 前两个是有关依赖
sudo apt install zlib1g libfreeimage-dev libcudnn8*
# cuDNN installation test
cp -r /usr/src/cudnn_samples_v8 ~/
cd cudnn_samples_v8/mnistCUDNN
make
./mnistCUDNN
# Test passed!  则安装成功
```

## PATH添加

```
/usr/local/cuda/bin添加到/etc/environment
```

## nvvp打不开解决方案

https://docs.nvidia.com/cuda/profiler-users-guide/index.html#setting-up-java-runtime-environment

```shell
# 原因jdk8未安装
sudo apt install openjdk-8-jdk openjdk-11-jdk
# method1
sudo update-java-alternatives --set java-1.8.0-openjdk-amd64
# 恢复11
sudo update-java-alternatives --set java-1.11.0-openjdk-amd64

# method2 nvvp启动脚本中指定vm
# 启动脚本/usr/local/cuda-11.8/bin/nvvp中最后的nvvp $@改为如下:
# nvvp -vm /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java $@
sudo sed -i 's|$CUDA_BIN/../libnvvp/nvvp $@|$CUDA_BIN/../libnvvp/nvvp -vm /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java $@|' /usr/local/cuda-11.8/bin/nvvp
```

## tensorrt

```shell
sudo apt install tensorrt
```

## tensorflow

.successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
参考：https://gist.github.com/zrruziev/b93e1292bf2ee39284f834ec7397ee9f

```bash
cat /sys/bus/pci/devices/0000\:01\:00.0/numa_node
sudo echo 0 | sudo tee -a /sys/bus/pci/devices/0000\:01\:00.0/numa_node
cat /sys/bus/pci/devices/0000\:01\:00.0/numa_node
```

https://www.tensorflow.org/install/source#tested_build_configurations

### clang安装

```bash
sudo cat <<EOF |sudo tee /etc/apt/sources.list.d/llvm.list
deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-16 main
deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy-16 main
EOF
wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
sudo apt install clang-16 lldb-16 lld-16 clangd-16 clang-tidy-16 clang-format-16 clang-tools-16 llvm-16-dev lld-16 lldb-16 llvm-16-tools libomp-16-dev libc++-16-dev libc++abi-16-dev libclang-common-16-dev libclang-16-dev libclang-cpp16-dev libunwind-16-dev libclang-rt-16-dev libpolly-16-dev
```

### 编译

```bash
# 编译tensorflow
# v2.13.0  
# clang16路径 /usr/lib/llvm-16/bin/clang
# include冲突解决
sudo mkdir /usr/include/clang/16/include/cuda_wrappers/bits
sudo cat <<EOF | sudo tee /usr/include/clang/16/include/cuda_wrappers/bits/shared_ptr_base.h
// CUDA headers define __noinline__ which interferes with libstdc++'s use of
// `__attribute((__noinline__))`. In order to avoid compilation error,
// temporarily unset __noinline__ when we include affected libstdc++ header.

#pragma push_macro("__noinline__")
#undef __noinline__
#include_next "bits/shared_ptr_base.h"

#pragma pop_macro("__noinline__")
EOF
# 开始编译
workon venv4build
bazel clean --expunge
bazel build --config=opt --copt=-march=native --cxxopt=-march=native --copt=-Wno-gnu-offsetof-extensions //tensorflow/tools/pip_package:build_pip_package
./bazel-bin/tensorflow/tools/pip_package/build_pip_package /home/username/projects/tmp/tensorflow_pkg
pip install --force-reinstall /home/username/projects/tmp/tensorflow_pkg2/tensorflow-2.13.0-cp310-cp310-linux_x86_64.whl
```

## pytorch

```bash
workon venv_ai_1
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```



# AMD核显驱动

**~~可以装但没必要，目前支持不完善，等22.04.3再看看支持程度如何~~**

**内核自带核显驱动，无需安装**

## AMD独显驱动操作

https://www.amd.com/en/support/linux-drivers

```shell
sudo dpkg -i debfilename
sudo amdgpu-install
```

==如果要安装新版本，先使用amdgpu-uninstall卸载旧驱动，再使用amdgpu-install 安装新驱动==

使用下列命令消除unattended-upgrade消息

```bash
sudo cat <<EOF | sudo tee /etc/apt/preferences.d/repo-radeon-pin-600
Package: rocminfo
Pin: origin *huaweicloud.com*
Pin-Priority: -1

Package: rocminfo
Pin: origin *edu.cn*
Pin-Priority: -1

Package: *
Pin: release o=repo.radeon.com
Pin-Priority: 600
EOF
```

​	
