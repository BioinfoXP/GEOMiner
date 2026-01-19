#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_menu() {
    echo -e "${BLUE}==============================${NC}"
    echo -e "      Git 助手脚本      "
    echo -e "${BLUE}==============================${NC}"
    echo "1. 查看状态 (git status)"
    echo "2. 拉取更新 (git pull)"
    echo "3. 提交并推送 (add + commit + push)"
    echo "4. 仅推送 (git push)"
    echo "5. 强制推送 (git push --force)"
    echo "0. 退出"
    echo -e "${BLUE}==============================${NC}"
}

# 获取当前分支
BRANCH=$(git symbolic-ref --short HEAD)

while true; do
    show_menu
    read -p "请输入选项 [0-5]: " choice
    
    case $choice in
        1)
            git status
            ;;
        2)
            echo -e "${YELLOW}正在从 origin/${BRANCH} 拉取代码...${NC}"
            git pull origin $BRANCH
            ;;
        3)
            git status -s
            echo ""
            read -p "请输入 Commit 信息 (直接回车默认 'Update'): " msg
            if [ -z "$msg" ]; then
                msg="Update"
            fi
            
            echo -e "${GREEN}执行: git add .${NC}"
            git add .
            
            echo -e "${GREEN}执行: git commit${NC}"
            git commit -m "$msg"
            
            # 拉取远程更改并推送
            echo -e "${YELLOW}正在从 origin/${BRANCH} 拉取代码...${NC}"
            git pull origin $BRANCH
            
            echo -e "${GREEN}执行: git push origin $BRANCH${NC}"
            git push origin $BRANCH
            ;;
        4)
            echo -e "${YELLOW}正在从 origin/${BRANCH} 拉取代码...${NC}"
            git pull origin $BRANCH
            echo -e "${GREEN}执行: git push origin $BRANCH${NC}"
            git push origin $BRANCH
            ;;
        5)
            echo -e "${GREEN}执行: git push --force origin $BRANCH${NC}"
            git push --force origin $BRANCH
            # 拉取最新的远程内容
            echo -e "${YELLOW}强制推送后拉取最新的代码...${NC}"
            git pull origin $BRANCH
            ;;
        0)
            echo "Bye!"
            exit 0
            ;;
        *)
            echo -e "${RED}无效选项，请重试${NC}"
            ;;
    esac
    echo ""
    read -p "按回车键继续..."
done
