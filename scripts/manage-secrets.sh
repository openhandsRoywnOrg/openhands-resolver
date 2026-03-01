#!/bin/bash

# 🔐 OpenHands Secrets 管理脚本
# 用于批量配置仓库 Secrets

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印函数
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 检查依赖
check_dependencies() {
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) 未安装"
        echo "请安装：https://cli.github.com/"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        print_error "未登录 GitHub"
        echo "请运行：gh auth login"
        exit 1
    fi
    
    print_success "依赖检查通过"
}

# 配置单个仓库的 Secrets
configure_repo_secrets() {
    local repo=$1
    local owner=$2
    
    print_info "正在配置仓库：$owner/$repo"
    
    # 检查仓库是否存在
    if ! gh repo view "$owner/$repo" &> /dev/null; then
        print_error "仓库 $owner/$repo 不存在"
        return 1
    fi
    
    # 配置 Secrets（从全局 Secrets 读取）
    # 注意：GitHub CLI 无法直接读取全局 Secrets，需要手动输入或使用环境变量
    
    if [ -n "$LLM_API_KEY" ]; then
        echo "$LLM_API_KEY" | gh secret set LLM_API_KEY --repo "$owner/$repo" && \
            print_success "LLM_API_KEY 已配置" || \
            print_warning "LLM_API_KEY 配置失败"
    else
        print_warning "LLM_API_KEY 未设置，请手动配置"
    fi
    
    if [ -n "$LLM_BASE_URL" ]; then
        echo "$LLM_BASE_URL" | gh secret set LLM_BASE_URL --repo "$owner/$repo" && \
            print_success "LLM_BASE_URL 已配置"
    fi
    
    if [ -n "$PAT_TOKEN" ]; then
        echo "$PAT_TOKEN" | gh secret set PAT_TOKEN --repo "$owner/$repo" && \
            print_success "PAT_TOKEN 已配置"
    fi
    
    if [ -n "$PAT_USERNAME" ]; then
        echo "$PAT_USERNAME" | gh secret set PAT_USERNAME --repo "$owner/$repo" && \
            print_success "PAT_USERNAME 已配置"
    fi
    
    # 配置 Variables
    gh variable set LLM_MODEL --body "openai/qwen3.5-plus" --repo "$owner/$repo" && \
        print_success "LLM_MODEL 变量已配置"
    
    gh variable set TARGET_BRANCH --body "main" --repo "$owner/$repo" && \
        print_success "TARGET_BRANCH 变量已配置"
    
    print_success "仓库 $owner/$repo 配置完成"
    echo ""
}

# 批量配置多个仓库
batch_configure() {
    local owner=$1
    shift
    local repos=("$@")
    
    print_info "开始批量配置 ${#repos[@]} 个仓库"
    echo ""
    
    for repo in "${repos[@]}"; do
        configure_repo_secrets "$repo" "$owner"
    done
    
    print_success "批量配置完成"
}

# 创建新项目
create_new_project() {
    local project_name=$1
    local description=${2:-"Auto-generated project from OpenHands template"}
    local is_private=${3:-false}
    local template_repo="tigerbreak/openhands-resolver"
    
    print_info "创建新项目：$project_name"
    
    # 从模板创建
    gh repo create "$project_name" \
        --template "$template_repo" \
        --description "$description" \
        --private="$is_private" \
        --source="$template_repo" \
        --remote && \
        print_success "项目创建成功：https://github.com/tigerbreak/$project_name"
    
    echo ""
    print_info "请手动配置 Secrets:"
    echo "1. 访问：https://github.com/tigerbreak/$project_name/settings/secrets/actions"
    echo "2. 添加 LLM_API_KEY, PAT_TOKEN 等"
    echo ""
    echo "或使用命令行:"
    echo "  gh secret set LLM_API_KEY --repo tigerbreak/$project_name"
    echo "  gh secret set PAT_TOKEN --repo tigerbreak/$project_name"
}

# 显示帮助
show_help() {
    cat << EOF
🔐 OpenHands Secrets 管理工具

用法:
  $0 <command> [options]

命令:
  configure <repo>           配置单个仓库的 Secrets
  batch <repo1> <repo2> ...  批量配置多个仓库
  create <name> [desc]       从模板创建新项目
  help                       显示此帮助信息

示例:
  $0 configure my-project
  $0 batch project1 project2 project3
  $0 create my-new-project "项目描述"

环境变量:
  LLM_API_KEY       LLM API 密钥
  LLM_BASE_URL      LLM API 基础 URL
  PAT_TOKEN         GitHub Personal Access Token
  PAT_USERNAME      GitHub 用户名

注意:
  - 需要安装 GitHub CLI (gh)
  - 需要先运行 gh auth login 登录

EOF
}

# 主函数
main() {
    local command=${1:-help}
    shift || true
    
    case "$command" in
        configure)
            if [ -z "$1" ]; then
                print_error "请指定仓库名"
                exit 1
            fi
            check_dependencies
            configure_repo_secrets "$1" "tigerbreak"
            ;;
        batch)
            if [ -z "$1" ]; then
                print_error "请指定至少一个仓库名"
                exit 1
            fi
            check_dependencies
            batch_configure "tigerbreak" "$@"
            ;;
        create)
            if [ -z "$1" ]; then
                print_error "请指定项目名"
                exit 1
            fi
            check_dependencies
            create_new_project "$@"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "未知命令：$command"
            show_help
            exit 1
            ;;
    esac
}

# 执行
main "$@"
