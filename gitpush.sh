#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

die() { echo -e "${RED}$*${NC}" >&2; exit 1; }

# 确保在 Git 仓库里，并切到仓库根目录，避免扫到 ../../ 或家目录
ensure_repo_root() {
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null)" || die "当前目录不在 Git 仓库中。请 cd 到项目目录后再运行。"
  cd "$root" || die "无法进入仓库根目录: $root"
}

current_branch() {
  # detached HEAD 时返回空
  git symbolic-ref --short -q HEAD 2>/dev/null || true
}

show_menu() {
  echo -e "${BLUE}==============================${NC}"
  echo -e "      Git 助手脚本      "
  echo -e "${BLUE}==============================${NC}"
  echo "仓库: $(pwd)"
  local br
  br="$(current_branch)"
  if [[ -n "${br}" ]]; then
    echo "分支: ${br}"
  else
    echo -e "分支: ${YELLOW}(detached HEAD / 未在分支上)${NC}"
  fi
  echo -e "${BLUE}==============================${NC}"
  echo "1. 查看状态 (git status)"
  echo "2. 拉取更新 (git pull --rebase)"
  echo "3. 提交并推送 (安全 add + commit + push)"
  echo "4. 仅推送 (git push)"
  echo "0. 退出"
  echo -e "${BLUE}==============================${NC}"
}

ensure_repo_root

while true; do
  show_menu
  read -r -p "请输入选项 [0-4]: " choice

  case "${choice}" in
    1)
      git status
      ;;
    2)
      br="$(current_branch)"
      [[ -n "${br}" ]] || die "当前是 detached HEAD，无法确定要 pull 的分支。请先 git switch <branch>。"
      echo -e "${YELLOW}正在拉取 origin/${br} (rebase)...${NC}"
      git pull --rebase origin "${br}"
      ;;
    3)
      br="$(current_branch)"
      [[ -n "${br}" ]] || die "当前是 detached HEAD，无法提交/推送到分支。请先 git switch <branch>。"

      git status -sb
      echo ""

      read -r -p "请输入 Commit 信息 (直接回车默认 'Update'): " msg
      [[ -n "${msg}" ]] || msg="Update"

      echo -e "${GREEN}选择 add 方式:${NC}"
      echo "1) 仅添加已跟踪文件的修改（推荐，避免把一堆新文件/目录加进去）"
      echo "2) 也添加未跟踪文件（等同 git add .）"
      read -r -p "请选择 [1-2] (默认 1): " addmode
      [[ -n "${addmode}" ]] || addmode="1"

      if [[ "${addmode}" == "2" ]]; then
        echo -e "${GREEN}执行: git add .${NC}"
        git add .
      else
        echo -e "${GREEN}执行: git add -u${NC}"
        git add -u
      fi

      # 没有变更就不 commit
      if git diff --cached --quiet; then
        echo -e "${YELLOW}暂存区没有变更，跳过 commit/push。${NC}"
      else
        echo -e "${GREEN}执行: git commit -m \"${msg}\"${NC}"
        git commit -m "${msg}"

        echo -e "${GREEN}执行: git push origin ${br}${NC}"
        git push origin "${br}"
      fi
      ;;
    4)
      br="$(current_branch)"
      [[ -n "${br}" ]] || die "当前是 detached HEAD，无法 push。请先 git switch <branch>。"
      echo -e "${GREEN}执行: git push origin ${br}${NC}"
      git push origin "${br}"
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
  read -r -p "按回车键继续..."
done
