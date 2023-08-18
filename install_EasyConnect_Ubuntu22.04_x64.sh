#!/bin/bash

# 函数：输出错误信息并退出
print_error_and_exit() {
    echo "Error: $1"
    exit 1
}

# 步骤1：检查并创建/tmp/sangforinstallationtemp目录
if [ ! -d "/tmp/sangforinstallationtemp" ]; then
    mkdir "/tmp/sangforinstallationtemp" || print_error_and_exit "Failed to create /tmp/sangforinstallationtemp"
else
    rm -rf "/tmp/sangforinstallationtemp" || print_error_and_exit "Failed to delete /tmp/sangforinstallationtemp"
    mkdir "/tmp/sangforinstallationtemp" || print_error_and_exit "Failed to create /tmp/sangforinstallationtemp"
fi

# 步骤2：下载文件
download_files=(
    "https://download.sangfor.com.cn/download/product/sslvpn/pkg/linux_767/EasyConnect_x64_7_6_7_3.deb"
    # 版本过高则替换如下 "https://download.sangfor.com.cn/download/product/sslvpn/pkg/linux_01/EasyConnect_x64.deb"
    "https://launchpadlibrarian.net/438303557/libpango-1.0-0_1.42.4-7_amd64.deb"
    "https://launchpadlibrarian.net/438303558/libpangocairo-1.0-0_1.42.4-7_amd64.deb"
    "https://launchpadlibrarian.net/438303559/libpangoft2-1.0-0_1.42.4-7_amd64.deb"
)

for url in "${download_files[@]}"; do
    wget -P "/tmp/sangforinstallationtemp" "$url" || print_error_and_exit "Download Failed"
done

# 步骤3：创建/tmp/sangforinstallationtemp/tmp目录
mkdir "/tmp/sangforinstallationtemp/tmp" || print_error_and_exit "Failed to create /tmp/sangforinstallationtemp/tmp"

# 解压lib开头的文件
for file in /tmp/sangforinstallationtemp/*.deb; do
  if [[ $file == /tmp/sangforinstallationtemp/lib* ]]; then
    dpkg -X "$file" "/tmp/sangforinstallationtemp/tmp" || print_error_and_exit "Failed to extract files"
  fi
done

# 步骤4：安装EasyConnect
sudo dpkg -i /tmp/sangforinstallationtemp/EasyConnect_x64_7_6_7_3.deb || print_error_and_exit "Failed to install EasyConnect"

# 步骤5：复制文件
sudo cp /tmp/sangforinstallationtemp/tmp/usr/lib/x86_64-linux-gnu/* /usr/share/sangfor/EasyConnect || print_error_and_exit "Failed to copy files"

# 步骤6：运行EasyConnect
/usr/share/sangfor/EasyConnect/EasyConnect || print_error_and_exit "Failed to run EasyConnect"

# 步骤7：删除/tmp/sangforinstallationtemp目录
rm -rf "/tmp/sangforinstallationtemp"
