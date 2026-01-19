#!/bin/sh
set -eu

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

die() { printf "%b\n" "${RED}$*${NC}" >&2; exit 1; }

# 获取脚本所在目录（POSIX 版；不处理复杂的多层 symlink 链）
script_dir() {
  case "$0" in
    */*) (cd "${0%/*}" 2>/dev/null && pwd) ;;
    *) pwd ;;
  esac
}

ensure_repo_root() {
  base="$(script_dir)"
  root="$(git -C "$base" rev-parse --show-toplevel 2>/dev/null)" || die "脚本目录不在 Git 仓库中: $base  (请把脚本放到项目内，或从项目内运行)"
  cd "$root" || die "无法进入仓库根目录: $root"
}

current_branch() {
  git symbolic-ref --short -q HEAD 2>/dev/null || true
}

show_menu() {
  printf "%b\n" "${BLUE}==============================${NC}"
  printf "%s\n" "      Git 助手脚本      "
  printf "%b\n" "${BLUE}==============================${NC}"
  printf "%s\n" "仓库: $(pwd)"

  br="$(current_branch)"
  if [ -n "${br}" ]; then
    printf "%s\n" "分支: ${br}"
  else
    printf "%b\n" "分支: ${YELLOW}(detached HEAD / 未在分支上)${NC}"
  fi

  printf "%b\n" "${BLUE}==============================${NC}"
  printf "%s\n" "1. 查看状态 (git status)"
  printf "%s\n" "2. 拉取更新 (git pull --rebase)"
  printf "%s\n" "3. 提交并推送 (安全 add + commit + push)"
  printf "%s\n" "4. 仅推送 (git push)"
  printf "%s\n" "5. 强制推送 (git push --force-with-lease)"
  printf "%s\n" "0. 退出"
  printf "%b\n" "${BLUE}==============================${NC}"
}

ensure_repo_root

while :; do
  show_menu
  printf "%s" "请输入选项 [0-5]: "
  IFS= read -r choice || exit 0

  case "${choice}" in
    1)
      git status
      ;;
    2)
      br="$(current_branch)"
      [ -n "${br}" ] || die "当前是 detached HEAD，无法确定要 pull 的分支。请先 git switch <branch>。"
      printf "%b\n" "${YELLOW}正在拉取 origin/${br} (rebase)...${NC}"
      git pull --rebase origin "${br}"
      ;;
    3)
      br="$(current_branch)"
      [ -n "${br}" ] || die "当前是 detached HEAD，无法提交/推送到分支。请先 git switch <branch>。"

      git status -sb
      printf "\n"

      printf "%s" "请输入 Commit 信息 (直接回车默认 'Update'): "
      IFS= read -r msg || msg=""
      [ -n "${msg}" ] || msg="Update"

      printf "%b\n" "${GREEN}选择 add 方式:${NC}"
      printf "%s\n" "1) 仅添加已跟踪文件的修改（推荐）"
      printf "%s\n" "2) 也添加未跟踪文件（等同 git add .）"
      printf "%s" "请选择 [1-2] (默认 1): "
      IFS= read -r addmode || addmode=""
      [ -n "${addmode}" ] || addmode="1"

      if [ "${addmode}" = "2" ]; then
        printf "%b\n" "${GREEN}执行: git add .${NC}"
        git add .
      else
        printf "%b\n" "${GREEN}执行: git add -u${NC}"
        git add -u
      fi

      if git diff --cached --quiet; then
        printf "%b\n" "${YELLOW}暂存区没有变更，跳过 commit/push。${NC}"
      else
        printf "%b\n" "${GREEN}执行: git commit -m \"${msg}\"${NC}"
        git commit -m "${msg}"

        printf "%b\n" "${GREEN}执行: git push origin ${br}${NC}"
        git push origin "${br}"
      fi
      ;;
    4)
      br="$(current_branch)"
      [ -n "${br}" ] || die "当前是 detached HEAD，无法 push。请先 git switch <branch>。"
      printf "%b\n" "${GREEN}执行: git push origin ${br}${NC}"
      git push origin "${br}"
      ;;
    5)
      br="$(current_branch)"
      [ -n "${br}" ] || die "当前是 detached HEAD，无法 push。请先 git switch <branch>。"
      printf "%b\n" "${YELLOW}警告: 将执行强制推送(安全模式 --force-with-lease) 到 origin/${br}${NC}"
      printf "%s" "确认强制推送? 输入 yes 继续: "
      IFS= read -r confirm || confirm=""
      if [ "${confirm}" = "yes" ]; then
        printf "%b\n" "${GREEN}执行: git push --force-with-lease origin ${br}${NC}"
        git push --force-with-lease origin "${br}"
      else
        printf "%b\n" "${YELLOW}已取消强制推送${NC}"
      fi
      ;;
    0)
      printf "%s\n" "Bye!"
      exit 0
      ;;
    *)
      printf "%b\n" "${RED}无效选项，请重试${NC}"
      ;;
  esac

  printf "\n"
  printf "%s" "按回车键继续..."
  IFS= read -r _ || true
done
