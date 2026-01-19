#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 获取当前分支，处理 Detached HEAD 情况
get_current_branch() {
    git symbolic-ref --short HEAD 2>/dev/null || echo "DETACHED_HEAD"
}

BRANCH=$(get_current_branch)

show_menu() {
    echo -e "${BLUE}==============================${NC}"
    echo -e "      Git 助手 (当前分支: ${YELLOW}${BRANCH}${BLUE})      "
    echo -e "${BLUE}==============================${NC}"
    echo "1. 查看状态 (git status)"
    echo "2. 拉取更新 (git pull)"
    echo "3. 提交并推送 (add + commit + pull + push)"
    echo "4. 仅推送 (pull + push)"
    echo -e "${RED}5. 强制推送 (git push --force)${NC}"
    echo "0. 退出"
    echo -e "${BLUE}==============================${NC}"
}

# 检查是否在 git 仓库中
if [ ! -d ".git" ]; then
    echo -e "${RED}错误: 当前目录不是 Git 仓库！${NC}"
    exit 1
fi

if [ "$BRANCH" == "DETACHED_HEAD" ]; then
    echo -e "${RED}警告: 当前处于 Detached HEAD 状态，请先切换到具体分支！${NC}"
    exit 1
fi

while true; do
    show_menu
    read -p "请输入选项 [0-5]: " choice
    
    case $choice in
        1)
            git status
            ;;
        2)
            echo -e "${YELLOW}正在拉取 origin/${BRANCH}...${NC}"
            git pull origin "$BRANCH"
            ;;
        3)
            git status -s
            echo ""
            
            # 检查是否有变更需要提交
            if [ -z "$(git status --porcelain)" ]; then
                echo -e "${YELLOW}没有检测到更改，无需提交。${NC}"
            else
                read -p "请输入 Commit 信息 (默认为 'Update'): " msg
                msg=${msg:-"Update"}
                
                echo -e "${GREEN}执行: git add .${NC}"
                git add .
                
                echo -e "${GREEN}执行: git commit${NC}"
                git commit -m "$msg"
                
                # 只有 commit 成功才继续
                if [ $? -eq 0 ]; then
                    echo -e "${YELLOW}正在拉取远程更新以避免冲突...${NC}"
                    if git pull origin "$BRANCH"; then
                        echo -e "${GREEN}执行: git push origin $BRANCH${NC}"
                        git push origin "$BRANCH"
                    else
                        echo -e "${RED}拉取失败（可能存在冲突），已停止推送。请手动解决冲突。${NC}"
                    fi
                fi
            fi
            ;;
        4)
            echo -e "${YELLOW}为了安全，推送前先尝试拉取...${NC}"
            if git pull origin "$BRANCH"; then
                echo -e "${GREEN}执行: git push origin $BRANCH${NC}"
                git push origin "$BRANCH"
            else
                echo -e "${RED}拉取失败（可能存在冲突），已停止推送。${NC}"
            fi
            ;;
        5)
            echo -e "${RED}警告：强制推送会覆盖远程仓库的历史记录，可能导致他人代码丢失！${NC}"
            read -p "确定要执行强制推送吗？(输入 'yes' 确认): " confirm
            if [ "$confirm" == "yes" ]; then
                echo -e "${GREEN}执行: git push --force origin $BRANCH${NC}"
                git push --force origin "$BRANCH"
                # 删除了这里多余的 git pull
            else
                echo -e "${YELLOW}操作已取消。${NC}"
            fi
            ;;
        0)
            echo "Bye!"
            exit 0
            ;;
        *)
            echo -e "${RED}无效选项${NC}"
            ;;
    esac
    echo ""
    read -p "按回车键继续..."
done