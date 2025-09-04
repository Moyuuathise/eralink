#!/bin/bash

# 项目名称: 随行终端 ERALINK
# 作者:     404nyaFound
# 版本：    v2.0.0
# 最后更新: 2025-08-31

# 初始化设置
set -euo pipefail
IFS=$'\n\t'

# 全局变量
SCRIPT_NAME="eralink"
REPO_NAME="Moyuuathise/eralink"
ROOT=$(cd "/data/data/com.termux/files/home" && pwd)
APP_DIR="$ROOT/$SCRIPT_NAME"
ZIP_FILE="$ROOT/eralink.zip"
DEFAULT_PROXY="https://ghfast.top"
USE_PROXY=true
CURRENT_PROXY="$DEFAULT_PROXY"

# 错误提示
# 函数: 输出错误信息并退出
# 参数:
#   $1: 错误信息
#   $2: 退出码（默认1）
# 返回:
#   无
err() {
    echo -e "\033[31m错误: $1\033[0m" >&2
    exit "${2:-1}"
}

# 检查依赖
# 函数: 检查并安装缺失的依赖
# 参数: 无
# 返回: 无
check_deps() {
    local deps=(curl unzip git npm node jq expect)
    local missing=()
    for dep in "${deps[@]}"; do
        command -v "$dep" &>/dev/null || missing+=("$dep")
    done
    if [ "${#missing[@]}" -gt 0 ]; then
        read -rp $'\033[33m缺少依赖: ${missing[*]}，是否自动安装? (y/n): \033[0m' confirm
        [[ "$confirm" != "y" && "$confirm" != "Y" ]] && err "依赖不足，用户取消安装"
        echo -e "\033[36m安装依赖...\033[0m"
        if [[ "$PREFIX" == *"/com.termux"* ]]; then
            pkg update -y && pkg install -y "${missing[*]}" || err "Termux 依赖安装失败"
        else
            [ "$EUID" -ne 0 ] && err "非 Termux 环境需 root 权限"
            sudo apt update -y && sudo apt install -y "${missing[*]}" || err "Linux 依赖安装失败"
        fi
        echo -e "\033[32m依赖安装完成\033[0m"
    fi
}

# 安装 ERALINK
# 函数: 解压并安装 ERALINK
# 参数: 无
# 返回: 无
install_eralink() {
    echo -e "\033[36m开始安装随行终端 ERALINK...\033[0m"
    cd "$ROOT"
    if [[ -f "$ZIP_FILE" ]]; then
        echo -e "\033[36m找到本地压缩包 $ZIP_FILE，正在解压...\033[0m"
        unzip -o "$ZIP_FILE" -d "$ROOT" || err "解压失败"
        echo -e "\033[36m删除本地压缩包 $ZIP_FILE...\033[0m"
        rm -f "$ZIP_FILE" || echo -e "\033[33m警告: 无法删除 $ZIP_FILE\033[0m"
    else
        local target_url="https://github.com/$REPO_NAME/releases/latest/download/eralink.zip"
        [[ "$USE_PROXY" = true && -n "$CURRENT_PROXY" ]] && target_url="${CURRENT_PROXY%/}/$(echo "$target_url" | sed 's|https://||')"
        echo -e "\033[36m下载压缩包...\033[0m"
        curl -fL "$target_url" -o eralink.zip || err "下载失败"
        unzip -o eralink.zip -d "$ROOT" || err "解压失败"
        echo -e "\033[36m删除下载的压缩包 eralink.zip...\033[0m"
        rm -f eralink.zip || echo -e "\033[33m警告: 无法删除 eralink.zip\033[0m"
    fi
    chmod +x "$APP_DIR/core.sh"
    echo -e "\033[32m随行终端 ERALINK 安装完成\033[0m"
}

# 主函数
main() {
    # 检查是否已安装
    if [[ -d "$APP_DIR" && -f "$APP_DIR/core.sh" ]]; then
        echo -e "\033[36m检测到随行终端 ERALINK 已安装，直接启动...\033[0m"
        cd "$APP_DIR"
        exec bash ./core.sh
    fi

    # 显示安装页面并进行安装
    clear
    echo -e "\033[36m==============================================\033[0m"
    echo -e "\033[97m          随行终端 ERALINK 安装程序          \033[0m"
    echo -e "\033[36m==============================================\033[0m"
    check_deps
    install_eralink
    echo -e "\033[36m启动随行终端 ERALINK...\033[0m"
    cd "$APP_DIR"
    exec bash ./core.sh
}

main
