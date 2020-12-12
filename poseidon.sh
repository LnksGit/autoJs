#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

sh_ver="0.87"

font_color_up="\033[32m" && font_color_end="\033[0m" && error_color_up="\033[31m" && error_color_end="\033[0m"
info="${font_color_up}[提示]: ${font_color_end}"
error="${error_color_up}[错误]: ${error_color_end}"
note="\033[33m[警告]: \033[0m"
fder="./JsSet"
lnkstls_link="https://js.clapse.com"

if (($EUID != 0)); then
  echo -e "${error}仅在root环境下测试 !" && exit 1
fi

Release=$(cat /etc/os-release | grep "VERSION_ID" | awk -F '=' '{print $2}' | sed "s/\"//g")
if [ "$arch" = "x86_64" ]; then
  echo -e "${error}暂不支持 x86_64 以外系统 !" && exit 1
fi
if [[ -f /etc/redhat-release ]]; then
  Distributor="CentOS"
  Commad="yum"
elif cat /etc/issue | grep -Eqi "debian"; then
  Distributor="Debian"
  Commad="apt"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
  Distributor="Ubuntu"
  Commad="apt"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
  Distributor="CentOS"
  Commad="yum"
elif cat /proc/version | grep -Eqi "debian"; then
  Distributor="Debian"
  Commad="apt"
elif cat /proc/version | grep -Eqi "ubuntu"; then
  Distributor="Ubuntu"
  Commad="apt"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
  Distributor="CentOS"
  Commad="yum"
else
  echo -e "${error}未检测到系统版本！" && exit 1
fi

update_sh() {
  uname="poseidon.sh"
  echo -e "当前版本为 [ ${sh_ver} ]，开始检测最新版本..."
  local sh_new_ver=$(wget -qO- "${lnkstls_link}/${uname}" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
  [[ -z ${sh_new_ver} ]] && echo -e "${error}检测最新版本失败 !" && sleep 3s && start_menu
  if [[ ${sh_new_ver} != ${sh_ver} ]]; then
    echo -e "${info}发现新版本[ ${sh_new_ver} ]，是否更新？[Y/n]"
    read -p "(默认: y): " yn
    [[ -z "${yn}" ]] && yn="y"
    if [[ ${yn} == [Yy] ]]; then
      wget "${lnkstls_link}/${uname}.sh" && chmod +x ${uname}.sh
      echo -e "${info}脚本已更新为最新版本[ ${sh_new_ver} ] !" && exit 0
    else
      echo && echo "${info}已取消..." && echo
    fi
  else
    echo -e "${info}当前已是最新版本[ ${sh_new_ver} ] !"
    sleep 5s
    start_menu
  fi
}

upcs() {
  echo -e "${info}更新列表 update"
  ${Commad} update -y && echo -e "${info}更新完成 !"
}

add_crontab() {
  crontab -l 2>/dev/null >$0.temp
  echo "$*" >>$0.temp &&
    crontab $0.temp &&
    rm -f $0.temp &&
    echo -e "${info}添加crontab成功 !" && crontab -l
}

soucn() {
  if [ "$Distributor" = "Debian" ]; then
    cp -f /etc/apt/sources.list /etc/apt/sources.list.bakup
    case $Release in
    8)
      echo -e "${info}写入Debian8源 !"
      echo "deb http://mirrors.cloud.tencent.com/debian jessie main contrib non-free
        deb http://mirrors.cloud.tencent.com/debian jessie-updates main contrib non-free
        #deb http://mirrors.cloud.tencent.com/debian jessie-backports main contrib non-free
        #deb http://mirrors.cloud.tencent.com/debian jessie-proposed-updates main contrib non-free
        deb-src http://mirrors.cloud.tencent.com/debian jessie main contrib non-free
        deb-src http://mirrors.cloud.tencent.com/debian jessie-updates main contrib non-free
        #deb-src http://mirrors.cloud.tencent.com/debian jessie-backports main contrib non-free
        #deb-src http://mirrors.cloud.tencent.com/debian jessie-proposed-updates main contrib non-free" >/etc/apt/sources.list
      ;;
    9)
      echo -e "${info}写入Debian9源 !"
      echo "deb http://mirrors.cloud.tencent.com/debian stretch main contrib non-free
        deb http://mirrors.cloud.tencent.com/debian stretch-updates main contrib non-free
        #deb http://mirrors.cloud.tencent.com/debian stretch-backports main contrib non-free
        #deb http://mirrors.cloud.tencent.com/debian stretch-proposed-updates main contrib non-free
        deb-src http://mirrors.cloud.tencent.com/debian stretch main contrib non-free
        deb-src http://mirrors.cloud.tencent.com/debian stretch-updates main contrib non-free
        #deb-src http://mirrors.cloud.tencent.com/debian stretch-backports main contrib non-free
        #deb-src http://mirrors.cloud.tencent.com/debian stretch-proposed-updates main contrib non-free" >/etc/apt/sources.list
      ;;
    10)
      echo -e "${info}写入Debian10源 !"
      echo "deb https://mirrors.cloud.tencent.com/debian/ buster main contrib non-free
        deb https://mirrors.cloud.tencent.com/debian/ buster-updates main contrib non-free
        deb https://mirrors.cloud.tencent.com/debian/ buster-backports main contrib non-free
        deb https://mirrors.cloud.tencent.com/debian-security buster/updates main contrib non-free
        deb-src https://mirrors.cloud.tencent.com/debian/ buster main contrib non-free
        deb-src https://mirrors.cloud.tencent.com/debian/ buster-updates main contrib non-free
        deb-src https://mirrors.cloud.tencent.com/debian/ buster-backports main contrib non-free
        deb-src https://mirrors.cloud.tencent.com/debian-security buster/updates main contrib non-free" >/etc/apt/sources.list
      ;;
    *)
      echo -e "${error}未匹配到对应系统源,仅支持LTS版本 !" && exit 1
      ;;
    esac
  elif [ "$Distributor" = "Ubuntu" ]; then
    cp -f /etc/apt/sources.list /etc/apt/sources.list.bakup
    case $Release in
    16.04)
      echo -e "${info}写入ubuntu16.04源 !"
      echo "deb http://mirrors.cloud.tencent.com/ubuntu/ xenial main restricted universe multiverse
        deb http://mirrors.cloud.tencent.com/ubuntu/ xenial-security main restricted universe multiverse
        deb http://mirrors.cloud.tencent.com/ubuntu/ xenial-updates main restricted universe multiverse
        #deb http://mirrors.cloud.tencent.com/ubuntu/ xenial-proposed main restricted universe multiverse
        #deb http://mirrors.cloud.tencent.com/ubuntu/ xenial-backports main restricted universe multiverse
        deb-src http://mirrors.cloud.tencent.com/ubuntu/ xenial main restricted universe multiverse
        deb-src http://mirrors.cloud.tencent.com/ubuntu/ xenial-security main restricted universe multiverse
        deb-src http://mirrors.cloud.tencent.com/ubuntu/ xenial-updates main restricted universe multiverse
        #deb-src http://mirrors.cloud.tencent.com/ubuntu/ xenial-proposed main restricted universe multiverse
        #deb-src http://mirrors.cloud.tencent.com/ubuntu/ xenial-backports main restricted universe multiverse" >/etc/apt/sources.list
      ;;
    18.04)
      echo -e "${note}写入ubuntu18.04源 !"
      echo "deb http://mirrors.cloud.tencent.com/ubuntu/ bionic main restricted universe multiverse
        deb http://mirrors.cloud.tencent.com/ubuntu/ bionic-security main restricted universe multiverse
        deb http://mirrors.cloud.tencent.com/ubuntu/ bionic-updates main restricted universe multiverse
        #deb http://mirrors.cloud.tencent.com/ubuntu/ bionic-proposed main restricted universe multiverse
        #deb http://mirrors.cloud.tencent.com/ubuntu/ bionic-backports main restricted universe multiverse
        deb-src http://mirrors.cloud.tencent.com/ubuntu/ bionic main restricted universe multiverse
        deb-src http://mirrors.cloud.tencent.com/ubuntu/ bionic-security main restricted universe multiverse
        deb-src http://mirrors.cloud.tencent.com/ubuntu/ bionic-updates main restricted universe multiverse
        #deb-src http://mirrors.cloud.tencent.com/ubuntu/ bionic-proposed main restricted universe multiverse
        #deb-src http://mirrors.cloud.tencent.com/ubuntu/ bionic-backports main restricted universe multiverse" >/etc/apt/sources.list
      ;;
    20.04)
      echo -e "${note}写入ubuntu18.04源 !"
      echo "deb http://mirrors.cloud.tencent.com/ubuntu/ focal main restricted universe multiverse
deb http://mirrors.cloud.tencent.com/ubuntu/ focal-security main restricted universe multiverse
deb http://mirrors.cloud.tencent.com/ubuntu/ focal-updates main restricted universe multiverse
#deb http://mirrors.cloud.tencent.com/ubuntu/ focal-proposed main restricted universe multiverse
#deb http://mirrors.cloud.tencent.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src http://mirrors.cloud.tencent.com/ubuntu/ focal main restricted universe multiverse
deb-src http://mirrors.cloud.tencent.com/ubuntu/ focal-security main restricted universe multiverse
deb-src http://mirrors.cloud.tencent.com/ubuntu/ focal-updates main restricted universe multiverse
#deb-src http://mirrors.cloud.tencent.com/ubuntu/ focal-proposed main restricted universe multiverse
#deb-src http://mirrors.cloud.tencent.com/ubuntu/ focal-backports main restricted universe multiverse" >/etc/apt/sources.list
      ;;
    *)
      echo -e "${error}未匹配到对应系统源,仅支持LTS版本 !" && exit 1
      ;;
    esac
  elif [ "$Distributor" = "CentOS" ]; then
    cp -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bakup
    case $Release in
    7)
      echo -e "${info}写入centos7源 !"
      wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos7_base.repo
      ;;
    8)
      echo -e "${info}写入centos8源 !"
      wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos8_base.repo
      ;;
    *)
      echo -e "${error}未匹配到对应系统源,仅支持LTS版本 !" && exit 1
      ;;
    esac
  else
    echo -e "${error}未匹配到系统 !" && exit 1
  fi
  sleep 3s
  upcs
}
souret() {
  if [ "$Distributor" = "Debian" ] || [ "$Distributor" = "Ubuntu" ]; then
    if [ -e "/etc/apt/sources.list.bakup" ]; then
      cp -f /etc/apt/sources.list.bakup /etc/apt/sources.list && echo -e "${info}恢复完成 !"
    else
      echo -e "${error}未找到备份 !" && exit 1
    fi
  elif [ "$Distributor" = "CentOS" ]; then
    if [ -e "/etc/yum.repos.d/CentOS-Base.repo.bakup" ]; then
      cp -f /etc/yum.repos.d/CentOS-Base.repo.bakup /etc/yum.repos.d/CentOS-Base.repo && echo -e "${info}恢复完成 !"
    else
      echo -e "${error}未找到备份 !" && exit 1
    fi
  fi
  upcs
}

wget_bbr() {
  cd $fder
  local bbrrss="https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh"
  if [ ! -e "./tcp.sh" ]; then
    wget --no-check-certificate -O tcp.sh "${bbrrss}" && chmod +x tcp.sh
  fi
  ./tcp.sh
}

install_docker() {
  if [ ! $(command -v docker) ]; then
    echo -e "${info}开始安装docker..."
    curl -fsSL https://get.docker.com | bash
    curl -L -S "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod a+x /usr/local/bin/docker-compose
    rm -f $(which dc) && ln -s /usr/local/bin/docker-compose /usr/bin/dc >/dev/null
    systemctl start docker >/dev/null && echo -e "${info}docker安装完成"
  else
    echo -e "${info}Docker已安装 !"
  fi
}

set_tcp_config() {
  local tcp_config="https://raw.githubusercontent.com/ColetteContreras/v2ray-poseidon/master/docker/v2board/tcp/config.json"
  local docker_tcp_config="https://raw.githubusercontent.com/ColetteContreras/v2ray-poseidon/master/docker/v2board/tcp/docker-compose.yml"
  read -p "节点id(默认1): " node_id
  node_id=${node_id:-1}
  read -p "webapi(http or https): " webapi
  read -p "token: " token
  read -p "节点限速(默认0): " node_speed
  node_speed=${node_speed:-0}
  read -p "用户ip限制(默认0): " user_ip
  user_ip=${user_ip:-0}
  read -p "用户限速(默认0): " user_speed
  user_speed=${user_speed:-0}

  read -p "容器名称(默认v2ray-tcp): " dc_name
  dc_name=${dc_name:-v2ray-tcp}
  read -p "服务端口(80:80): " dc_port
  dc_port=${dc_port:-80:80}

  if [ -d "$dc_name" ]; then
    echo -e "${error}容器名称重复 !"
    sleep 3s
    set_tcp_config
  fi

  mkdir $dc_name
  cd $dc_name
  if [ -n "$webapi" -a -n "$token" ]; then
    curl -sSL $tcp_config | sed "4s/1/${node_id}/g" | sed "6s|http or https://YOUR V2BOARD DOMAIN|${webapi}|g" | sed "7s/v2board token/${token}/g" | sed "9s/0/${node_speed}/g" | sed "11s/0/${user_ip}/g" | sed "12s/0/${user_speed}/g" >config.json
    curl -sSL $docker_tcp_config | sed "s/v2ray-tcp/${dc_name}/g" | sed "s/服务端口:服务端口/${dc_port}/g" | sed "s/2g/100m/g" >docker-compose.yml && echo -e "${info}配置文件完成"
    docker-compose up -d && echo $dc_name && docker-compose logs -f
  else
    echo -e "${error}输入错误 !"
    sleep 3s
    set_ws_config
  fi
}

set_ws_config() {
  local ws_config="https://raw.githubusercontent.com/ColetteContreras/v2ray-poseidon/master/docker/v2board/ws/config.json"
  local docker_ws_config="https://raw.githubusercontent.com/ColetteContreras/v2ray-poseidon/master/docker/v2board/ws/docker-compose.yml"

  read -p "节点id(默认1): " node_id
  node_id=${node_id:-1}
  read -p "webapi(http or https): " webapi
  read -p "token: " token
  read -p "节点限速(默认0): " node_speed
  node_speed=${node_speed:-0}
  read -p "用户ip限制(默认0): " user_ip
  user_ip=${user_ip:-0}
  read -p "用户限速(默认0): " user_speed
  user_speed=${user_speed:-0}

  read -p "容器名称(默认v2ray-ws): " dc_name
  dc_name=${dc_name:-v2ray-ws}
  read -p "连接端口(80:10086): " dc_port
  dc_port=${dc_port:-80:10086}

  if [ -d "$dc_name" ]; then
    echo -e "${error}容器名称重复 !"
    sleep 3s
    set_ws_config
  fi

  mkdir $dc_name
  cd $dc_name

  if [ -n "$webapi" -a -n "$token" ]; then
    curl -sSL $ws_config | sed "4s/1/${node_id}/g" | sed "6s|http or https://YOUR V2BOARD DOMAIN|${webapi}|g" | sed "7s/v2board token/${token}/g" | sed "9s/0/${node_speed}/g" | sed "11s/0/${user_ip}/g" | sed "12s/0/${user_speed}/g" >config.json
    wget -O docker-compose.yml $docker_ws_config
    cat docker-compose.yml | sed "s/v2ray-ws/${dc_name}/g" | sed "s/80:10086/${dc_port}/g" | sed "s/2g/100m/g" >docker-compose.yml && echo -e "${info}配置文件完成"
    docker-compose up -d && echo $dc_name && docker-compose logs -f
  else
    echo -e "${error}输入错误 !"
    sleep 3s
    set_ws_config
  fi
}

install_poseidon() {
  if [ ! -e "v2" ]; then
    mkdir v2
  fi
  cd v2
  install_docker
  echo -e "
\033[2A
——————————————————————————————
${font_color_up}1.${font_color_end} TCP模式
${font_color_up}2.${font_color_end} WS模式
${font_color_up}3.${font_color_end} TLS模式
——————————————————————————————
${font_color_up}0.${font_color_end}返回上一步
    "
  read -p "请输入数字: " num
  case "$num" in
  0)
    start_menu
    ;;
  1)
    set_tcp_config
    ;;
  2)
    set_ws_config
    ;;
  *)
    echo -e "${error}输入错误 !"
    sleep 3s
    install_poseidon
    ;;
  esac

}

install_bt() {
  cd $fder
  local bt_link="http://download.bt.cn/install/install_panel.sh"
  curl -sSO ${bt_link} && bash install_panel.sh
}
rm_bt() {
  cd $fder
  local rmbt_link="http://download.bt.cn/install/bt-uninstall.sh"
  wget --no-check-certificate -O bt_uninstall.sh ${rmbt_link} && bash bt_uninstall.sh
}
install_hot() {
  cd $fder
  local hot_link="https://raw.githubusercontent.com/CokeMine/ServerStatus-Hotaru/master/status.sh"
  wget --no-check-certificate -O status.sh ${hot_link} && chmod +x status.sh && ./status.sh c
}
update_poseidon() {
  if [[ $(docker pull v2cc/poseidon:latest) == *"Image is up to date"* ]]; then
    docker images --digests
    echo -e "${info}已是最新版本 !"
  else
    docker restart $(docker ps -aq) && echo -e "${info}更新完成 !"
  fi
}

ddserver() {
  cd $fder
  local dd_link="https://raw.githubusercontent.com/veip007/dd/master/dd-gd.sh"
  if [ ! -e "dd-gd.sh" ]; then
    wget --no-check-certificate -O dd-gd.sh ${dd_link} && chmod +x dd-gd.sh
  fi
  ./dd-gd.sh
}

time_up() {
  if [ ! $(command -v ntpdate) ]; then
    ${Commad} -y install ntpdate
  fi
  timedatectl set-timezone 'Asia/Shanghai' && ntpdate -u pool.ntp.org && hwclock -w
  timedatectl
}


superspeed() {
  cd $fder
  superspeed_link="https://git.io/superspeed"
  wget --no-check-certificate -O superspeed.sh ${superspeed_link} && chmod +x superspeed.sh
  ./superspeed.sh
}

speedtest_install() {
  if [ "$Distributor" = "Debian" ] || [ "$Distributor" = "Ubuntu" ]; then
    apt -y install gnupg1 apt-transport-https dirmngr
    export INSTALL_KEY=379CE192D401AB61
    export DEB_DISTRO=$(lsb_release -sc)
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $INSTALL_KEY
    echo "deb https://ookla.bintray.com/debian ${DEB_DISTRO} main" | sudo tee /etc/apt/sources.list.d/speedtest.list
    apt update -y
    apt -y install speedtest && echo -e "${info}安装完成 !" && speedtest
  elif [ "$Distributor" = "CentOS" ]; then
    wget https://bintray.com/ookla/rhel/rpm -O bintray-ookla-rhel.repo
    mv bintray-ookla-rhel.repo /etc/yum.repos.d/
    yum install -y speedtest && echo -e "${info}安装完成 !" && speedtest
  else
    echo -e "${error}不受支持的系统 !" && exit 1
  fi
}

nat() {
  cd $fder
  local nat_link="https://arloor.com/sh/iptablesUtils/natcfg.sh"
  if [ ! -e "nat.sh" ]; then
    wget --no-check-certificate -O nat.sh ${nat_link} && chmod +x nat.sh
  fi
  ./nat.sh
}

dnspod() {
  cd $fder
  local dnspod_link="${lnkstls_link}/dnspod.sh"
  local dnspod_line_link="${lnkstls_link}/dnspod_line.sh"
  echo -e "
\033[2A
——————————————————————————————
${font_color_up}1.${font_color_end} 外网获取ip
${font_color_up}2.${font_color_end} 网卡获取
——————————————————————————————"
  read -p "请输入数字: " dnspod_re
  case "$dnspod_re" in
  1)
    if [ ! -e "dnspod.sh" ]; then
      wget --no-check-certificate -O dnspod.sh ${dnspod_link} && chmod +x dnspod.sh
    fi
    read -p "请输入APP_ID: " APP_ID
    read -p "请输入APP_Token: " APP_Token
    read -p "请输入Domain: " domain
    read -p "请输入Host: " host
    read -p "请输入TTL(默认600): " ttl
    ttl=${ttl:-600}
    ./dnspod.sh $APP_ID $APP_Token $domain $host $ttl &&
      add_crontab "* * * * * bash $(pwd)/dnspod.sh ${APP_ID} ${APP_Token} ${domain} ${host} ${ttl} >$(pwd)/dnspod.log"
    ;;
  2)
    if [ ! -e "dnspod_line.sh" ]; then
      wget --no-check-certificate -O dnspod.sh ${dnspod_line_link} && chmod +x dnspod_line.sh
    fi
    vim dnspod_line.sh
    ;;
  *)
    echo "${error}输入错误 !"
    sleep 3s
    dnspod
    ;;
  esac
}

besttrace() {
  cd $fder
  if [ ! -e "besttrace" ]; then
    wget --no-check-certificate "${lnkstls_link}/besttrace" && chmod +x besttrace
  fi
  read -p "IP or 域名: " ip
  ./besttrace -g cn $ip
}

haproxy() {
  if [ ! -e "haproxy.sh" ]; then
    wget --no-check-certificate "${lnkstls_link}/haproxy.sh"&& chmod +x haproxy.sh
  fi
  ./haproxy.sh
}

network_opt() {
  if cat /etc/security/limits.conf | grep -Eqi "soft nofile|soft noproc "; then
    echo -e "${error}已优化limits !"
  else
    echo "*   soft noproc   65535  
*   hard noproc   65535  
*   soft nofile   65535  
*   hard nofile   65535" >>/etc/security/limits.conf && echo -e "${info}limits设置完成 !"
  fi
  if cat /etc/profile | grep -Eqi "ulimit -u 65535"; then
    echo -e "${error}已优化profile !"
  else
    echo "ulimit -u 65535  
ulimit -n 65535
ulimit -d unlimited  
ulimit -m unlimited  
ulimit -s unlimited  
ulimit -t unlimited  
ulimit -v unlimited" >>/etc/profile && source /etc/profile && echo -e "${info}profile设置完成 !"
  fi
  read -p "需要重启VPS后，才能全局生效，是否现在重启 ? [Y/n] :" yn
  [ -z "${yn}" ] && yn="y"
  if [[ $yn == [Yy] ]]; then
    echo -e "${Info}重启中..."
    reboot
  fi
}

gost() {
  local gost_link="${lnkstls_link}/gost.sh"
  if [ ! -e gost.sh ]; then
    wget --no-check-certificate ${gost_link} && chmod +x gost.sh
  fi
  ./gost.sh
}

start_menu() {
  clear
  echo && echo -e "Author: by @Lnkstls
当前版本: [${sh_ver}]
——————————————————————————————
${font_color_up}0.${font_color_end} 升级脚本
——————————————————————————————
${font_color_up}1.${font_color_end} bbr安装脚本
${font_color_up}2.${font_color_end} 安装Docker、Docker-compose
${font_color_up}3.${font_color_end} 安装poseidon(docker版)
${font_color_up}4.${font_color_end} 更新poseidon(docker版)
${font_color_up}5.${font_color_end} 宝塔安装脚本(py3版)
${font_color_up}6.${font_color_end} 卸载宝塔脚本
${font_color_up}7.${font_color_end} Hotaru探针脚本
${font_color_up}9.${font_color_end} 一键dd系统脚本(萌咖)
${font_color_up}10.${font_color_end} 设置上海时区并对齐
${font_color_up}12.${font_color_end} 国内测速脚本(Superspeed)
${font_color_up}13.${font_color_end} 安装speedtest
${font_color_up}14.${font_color_end} nat脚本
${font_color_up}15.${font_color_end} ddns脚本(DnsPod)
${font_color_up}16.${font_color_end} bettrace路由测试
${font_color_up}17.${font_color_end} Haproxy脚本
${font_color_up}18.${font_color_end} 网络优化(实验性)
${font_color_up}19.${font_color_end} Gost脚本
——————————————————————————————
Ctrl+C 退出" && echo
  read -p "请输入数字: " num
  case "$num" in
  0)
    update_sh
    ;;
  1)
    wget_bbr
    ;;
  2)
    install_docker
    ;;
  3)
    install_poseidon
    ;;
  4)
    update_poseidon
    ;;
  5)
    install_bt
    ;;
  6)
    rm_bt
    ;;
  7)
    install_hot
    ;;
  9)
    ddserver
    ;;
  10)
    time_up
    ;;
  12)
    superspeed
    ;;
  13)
    speedtest_install
    ;;
  14)
    nat
    ;;
  15)
    dnspod
    ;;
  16)
    besttrace
    ;;
  17)
    haproxy
    ;;
  18)
    network_opt
    ;;
  19)
    gost
    ;;
  *)
    echo -e "${error}输入错误 !"
    sleep 3s
    start_menu
    ;;
  esac
}

ARGS=$(getopt -a -o :s:h -l source::,help -- "$@")
eval set -- "$ARGS"
for opt in "$@"; do
  case $opt in
  -s | --all)
    shift
    case $1 in
    cn)
      soucn
      ;;
    ret)
      souret
      ;;
    * | --)
      echo -e "${error}错误参数 !" && exit 1
      ;;
    esac
    break
    ;;
  -h | --help)
    echo -e "参数列表:
  -s  --source  cn 使用腾讯云镜像
                ret 恢复备份
  -h  --help    帮助"
    exit 1
    ;;
  esac
done

if [ ! -e "poseidon.log" ]; then
  upcs
  echo "1" >poseidon.log
fi
if [ ! -d "$fder" ]; then
  mkdir $fder
fi
if [ ! $(command -v sudo) ]; then
  echo -e "${info}安装依赖 sudo"
  ${Commad} -y install sudo
fi
if [ ! $(command -v wget) ]; then
  echo -e "${info}安装依赖 wget"
  ${Commad} -y install wget
fi
if [ ! $(command -v vim) ]; then
  echo -e "${info}安装依赖 vim"
  ${Commad} -y install vim
fi
if [ ! $(command -v unzip) ]; then
  echo -e "${info}安装依赖 unzip"
  ${Commad} -y install unzip
fi
if [ ! $(command -v curl) ]; then
  echo -e "${info}安装依赖 curl"
  ${Commad} -y install curl
fi
if [ ! $(command -v iperf3) ]; then
  echo -e "${info}安装依赖 iperf3"
  ${Commad} -y install iperf3
fi
if [ ! $(command -v screen) ]; then
  echo -e "${info}安装依赖 screen"
  ${Commad} -y install screen
fi

start_menu
