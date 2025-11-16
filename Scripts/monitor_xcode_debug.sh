#!/bin/bash

# Nota4 Xcode 调试监控脚本
# 自动捕获 Xcode console log 和 issues
# 用法: ./monitor_xcode_debug.sh [选项]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOGS_DIR="$PROJECT_ROOT/Logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SESSION_LOG="$LOGS_DIR/debug_session_$TIMESTAMP.log"
ISSUES_LOG="$LOGS_DIR/issues_$TIMESTAMP.log"
CONSOLE_LOG="$LOGS_DIR/console_$TIMESTAMP.log"
SUMMARY_LOG="$LOGS_DIR/summary_$TIMESTAMP.md"

# 创建日志目录
mkdir -p "$LOGS_DIR"

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$SESSION_LOG"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$SESSION_LOG"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$SESSION_LOG"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$SESSION_LOG"
}

print_section() {
    echo -e "\n${PURPLE}========================================${NC}" | tee -a "$SESSION_LOG"
    echo -e "${PURPLE}$1${NC}" | tee -a "$SESSION_LOG"
    echo -e "${PURPLE}========================================${NC}\n" | tee -a "$SESSION_LOG"
}

# 显示帮助信息
show_help() {
    cat << EOF
Nota4 Xcode 调试监控脚本

用法: $0 [选项]

选项:
    -h, --help              显示帮助信息
    -b, --build             构建项目并捕获日志
    -r, --run               运行项目并监控 console
    -c, --continuous        持续监控模式
    -a, --analyze           分析现有日志
    -l, --live              实时显示日志（默认后台运行）
    --clean                 清理旧日志

示例:
    $0 --build              # 构建并捕获编译日志
    $0 --run                # 运行并监控 console
    $0 --continuous         # 持续监控（适合交互测试）
    $0 --analyze            # 分析最近的日志

日志位置: $LOGS_DIR/
EOF
}

# 清理旧日志
clean_old_logs() {
    print_section "清理旧日志"
    
    if [ -d "$LOGS_DIR" ]; then
        # 保留最近 10 次的日志
        log_count=$(ls -1 "$LOGS_DIR"/*.log 2>/dev/null | wc -l | tr -d ' ')
        if [ "$log_count" -gt 30 ]; then
            print_info "发现 $log_count 个日志文件，清理旧文件..."
            cd "$LOGS_DIR"
            ls -t *.log 2>/dev/null | tail -n +31 | xargs rm -f
            print_success "已清理旧日志"
        else
            print_info "日志文件数量: $log_count (无需清理)"
        fi
    fi
}

# 获取项目信息
get_project_info() {
    print_section "获取项目信息"
    
    cd "$PROJECT_ROOT"
    
    # 检查 Package.swift
    if [ ! -f "Package.swift" ]; then
        print_error "未找到 Package.swift"
        exit 1
    fi
    
    print_info "项目路径: $PROJECT_ROOT"
    print_info "项目名称: Nota4"
    
    # 获取 Swift 版本
    swift_version=$(swift --version | head -n 1)
    print_info "Swift 版本: $swift_version"
    
    # 获取 Xcode 版本
    if command -v xcodebuild &> /dev/null; then
        xcode_version=$(xcodebuild -version | head -n 1)
        print_info "Xcode 版本: $xcode_version"
    fi
}

# 构建项目并捕获日志
build_project() {
    print_section "构建项目"
    
    cd "$PROJECT_ROOT"
    
    print_info "开始构建..."
    
    # 构建并捕获输出
    local build_log="$LOGS_DIR/build_$TIMESTAMP.log"
    
    if swift build 2>&1 | tee "$build_log"; then
        print_success "✅ 构建成功"
        
        # 提取警告
        local warnings=$(grep -i "warning:" "$build_log" | wc -l | tr -d ' ')
        if [ "$warnings" -gt 0 ]; then
            print_warning "发现 $warnings 个警告"
            grep -i "warning:" "$build_log" > "$ISSUES_LOG"
        fi
        
        return 0
    else
        print_error "❌ 构建失败"
        
        # 提取错误
        local errors=$(grep -i "error:" "$build_log" | wc -l | tr -d ' ')
        print_error "发现 $errors 个错误"
        grep -i "error:" "$build_log" > "$ISSUES_LOG"
        
        return 1
    fi
}

# 运行测试并捕获日志
run_tests() {
    print_section "运行测试"
    
    cd "$PROJECT_ROOT"
    
    print_info "开始测试..."
    
    local test_log="$LOGS_DIR/test_$TIMESTAMP.log"
    
    if swift test 2>&1 | tee "$test_log"; then
        print_success "✅ 测试通过"
        
        # 提取测试统计
        local test_count=$(grep -E "Test Case.*passed" "$test_log" | wc -l | tr -d ' ')
        print_info "通过测试: $test_count 个"
        
        return 0
    else
        print_error "❌ 测试失败"
        
        # 提取失败的测试
        grep -E "Test Case.*failed" "$test_log" >> "$ISSUES_LOG" 2>/dev/null || true
        
        return 1
    fi
}

# 监控应用运行日志
monitor_runtime() {
    print_section "监控运行时日志"
    
    print_info "开始监控应用日志..."
    print_info "请在 Xcode 中运行应用"
    print_info "按 Ctrl+C 停止监控"
    
    # 使用 log 命令监控系统日志
    # 过滤 Nota4 相关的日志
    log stream --predicate 'processImagePath contains "Nota4"' --level debug 2>&1 | while read -r line; do
        echo "$line" | tee -a "$CONSOLE_LOG"
        
        # 检测错误
        if echo "$line" | grep -qi "error"; then
            echo -e "${RED}[ERROR DETECTED]${NC} $line"
            echo "$line" >> "$ISSUES_LOG"
        fi
        
        # 检测警告
        if echo "$line" | grep -qi "warning"; then
            echo -e "${YELLOW}[WARNING DETECTED]${NC} $line"
        fi
        
        # 检测崩溃
        if echo "$line" | grep -qi "crash\|exception\|fatal"; then
            echo -e "${RED}[CRITICAL]${NC} $line"
            echo "$line" >> "$ISSUES_LOG"
        fi
    done
}

# 监控 Xcode DerivedData 日志
monitor_derived_data() {
    print_section "监控 Xcode DerivedData"
    
    local derived_data="$HOME/Library/Developer/Xcode/DerivedData"
    
    if [ ! -d "$derived_data" ]; then
        print_warning "未找到 DerivedData 目录"
        return 1
    fi
    
    # 查找最新的 Nota4 构建目录
    local nota4_build=$(find "$derived_data" -maxdepth 1 -type d -name "*Nota4*" -print0 | xargs -0 ls -td | head -n 1)
    
    if [ -z "$nota4_build" ]; then
        print_warning "未找到 Nota4 构建数据"
        return 1
    fi
    
    print_info "找到构建目录: $nota4_build"
    
    # 监控日志文件
    local logs_dir="$nota4_build/Logs"
    if [ -d "$logs_dir" ]; then
        print_info "监控构建日志..."
        
        # 查找最新的日志文件
        local latest_log=$(find "$logs_dir" -type f -name "*.xcactivitylog" -print0 | xargs -0 ls -t | head -n 1)
        
        if [ -n "$latest_log" ]; then
            print_info "最新日志: $latest_log"
            # 注意: .xcactivitylog 是二进制文件，需要特殊工具解析
            print_warning "xcactivitylog 需要使用 xclogparser 等工具解析"
        fi
    fi
}

# 分析日志并生成报告
analyze_logs() {
    print_section "分析日志"
    
    # 初始化计数器
    local error_count=0
    local warning_count=0
    local crash_count=0
    
    # 分析 issues 日志
    if [ -f "$ISSUES_LOG" ]; then
        error_count=$(grep -ci "error" "$ISSUES_LOG" 2>/dev/null || echo "0")
        warning_count=$(grep -ci "warning" "$ISSUES_LOG" 2>/dev/null || echo "0")
        crash_count=$(grep -ciE "crash|fatal|exception" "$ISSUES_LOG" 2>/dev/null || echo "0")
    fi
    
    # 生成摘要报告
    cat > "$SUMMARY_LOG" << EOF
# Nota4 调试会话摘要

**时间**: $(date '+%Y-%m-%d %H:%M:%S')  
**会话ID**: $TIMESTAMP

---

## 📊 统计信息

| 类型 | 数量 |
|------|------|
| 错误 (Errors) | $error_count |
| 警告 (Warnings) | $warning_count |
| 崩溃 (Crashes) | $crash_count |

---

## 📁 日志文件

- **会话日志**: \`$(basename "$SESSION_LOG")\`
- **问题日志**: \`$(basename "$ISSUES_LOG")\`
- **控制台日志**: \`$(basename "$CONSOLE_LOG")\`
- **摘要报告**: \`$(basename "$SUMMARY_LOG")\`

---

## 🔍 详细问题

EOF

    # 添加错误详情
    if [ -f "$ISSUES_LOG" ] && [ -s "$ISSUES_LOG" ]; then
        echo "### 错误和警告" >> "$SUMMARY_LOG"
        echo '```' >> "$SUMMARY_LOG"
        head -n 50 "$ISSUES_LOG" >> "$SUMMARY_LOG"
        echo '```' >> "$SUMMARY_LOG"
    else
        echo "### ✅ 未发现问题" >> "$SUMMARY_LOG"
    fi
    
    # 添加系统信息
    cat >> "$SUMMARY_LOG" << EOF

---

## 💻 系统信息

- **macOS**: $(sw_vers -productVersion)
- **Swift**: $(swift --version | head -n 1)
- **项目路径**: $PROJECT_ROOT

---

## 📝 建议

EOF

    # 根据问题提供建议
    if [ "$error_count" -gt 0 ]; then
        echo "- ❌ **发现 $error_count 个错误**，请先修复编译错误" >> "$SUMMARY_LOG"
    fi
    
    if [ "$warning_count" -gt 0 ]; then
        echo "- ⚠️ **发现 $warning_count 个警告**，建议修复以提高代码质量" >> "$SUMMARY_LOG"
    fi
    
    if [ "$crash_count" -gt 0 ]; then
        echo "- 🔴 **发现 $crash_count 个崩溃**，这是严重问题，需要立即修复" >> "$SUMMARY_LOG"
    fi
    
    if [ "$error_count" -eq 0 ] && [ "$warning_count" -eq 0 ] && [ "$crash_count" -eq 0 ]; then
        echo "- ✅ **没有发现问题**，代码质量良好！" >> "$SUMMARY_LOG"
    fi
    
    print_success "分析完成，报告已生成"
    print_info "摘要报告: $SUMMARY_LOG"
}

# 显示实时日志
show_live_logs() {
    print_section "实时日志监控"
    
    print_info "监控以下日志文件:"
    print_info "- 问题: $ISSUES_LOG"
    print_info "- 控制台: $CONSOLE_LOG"
    
    # 创建文件（如果不存在）
    touch "$ISSUES_LOG" "$CONSOLE_LOG"
    
    # 使用 tail -f 实时显示
    print_info "按 Ctrl+C 停止监控"
    
    tail -f "$ISSUES_LOG" "$CONSOLE_LOG" 2>/dev/null &
    local tail_pid=$!
    
    # 捕获 Ctrl+C
    trap "kill $tail_pid 2>/dev/null; print_info '停止监控'" EXIT
    
    wait $tail_pid
}

# 持续监控模式
continuous_monitor() {
    print_section "持续监控模式"
    
    print_info "开始持续监控..."
    print_info "适合在 Xcode 中交互测试时使用"
    print_info "按 Ctrl+C 停止"
    
    # 启动后台监控
    (
        while true; do
            # 监控应用日志
            log stream --predicate 'processImagePath contains "Nota4"' --level debug 2>&1 | while read -r line; do
                timestamp=$(date '+%H:%M:%S')
                echo "[$timestamp] $line" >> "$CONSOLE_LOG"
                
                # 检测关键词
                if echo "$line" | grep -qiE "error|warning|crash|fatal|exception"; then
                    echo "[$timestamp] $line" >> "$ISSUES_LOG"
                    echo -e "${RED}[$timestamp]${NC} $line"
                fi
            done
            
            sleep 1
        done
    ) &
    
    local monitor_pid=$!
    
    # 显示实时统计
    while true; do
        clear
        echo -e "${PURPLE}=== Nota4 实时监控 ===${NC}"
        echo ""
        echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        if [ -f "$CONSOLE_LOG" ]; then
            local log_lines=$(wc -l < "$CONSOLE_LOG" | tr -d ' ')
            echo "控制台日志: $log_lines 行"
        fi
        
        if [ -f "$ISSUES_LOG" ]; then
            local issue_lines=$(wc -l < "$ISSUES_LOG" | tr -d ' ')
            echo "问题日志: $issue_lines 行"
            
            if [ "$issue_lines" -gt 0 ]; then
                echo ""
                echo -e "${YELLOW}最近的问题:${NC}"
                tail -n 5 "$ISSUES_LOG"
            fi
        fi
        
        echo ""
        echo "日志目录: $LOGS_DIR"
        echo "按 Ctrl+C 停止监控并生成报告"
        
        sleep 2
    done
    
    # 清理
    trap "kill $monitor_pid 2>/dev/null; analyze_logs; print_success '监控已停止'" EXIT
}

# 主函数
main() {
    print_section "Nota4 Xcode 调试监控"
    
    # 记录开始时间
    echo "开始时间: $(date '+%Y-%m-%d %H:%M:%S')" > "$SESSION_LOG"
    
    # 解析参数
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        --clean)
            clean_old_logs
            exit 0
            ;;
        -b|--build)
            get_project_info
            build_project
            run_tests
            analyze_logs
            ;;
        -r|--run)
            get_project_info
            monitor_runtime
            analyze_logs
            ;;
        -c|--continuous)
            get_project_info
            continuous_monitor
            ;;
        -a|--analyze)
            # 分析最近的日志
            latest_issues=$(ls -t "$LOGS_DIR"/issues_*.log 2>/dev/null | head -n 1)
            latest_console=$(ls -t "$LOGS_DIR"/console_*.log 2>/dev/null | head -n 1)
            
            if [ -n "$latest_issues" ]; then
                ISSUES_LOG="$latest_issues"
            fi
            if [ -n "$latest_console" ]; then
                CONSOLE_LOG="$latest_console"
            fi
            
            analyze_logs
            ;;
        -l|--live)
            get_project_info
            show_live_logs
            ;;
        "")
            # 默认行为：构建 + 运行 + 监控
            print_info "使用默认模式：构建 -> 测试 -> 分析"
            get_project_info
            
            if build_project; then
                run_tests || true
            fi
            
            analyze_logs
            
            print_info ""
            print_info "提示: 使用以下命令进行其他操作:"
            print_info "  --continuous  : 持续监控（适合交互测试）"
            print_info "  --run        : 仅监控运行时日志"
            print_info "  --help       : 查看所有选项"
            ;;
        *)
            print_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
    
    # 显示报告位置
    print_success "✅ 完成"
    print_info ""
    print_info "📁 日志文件位置:"
    print_info "  $LOGS_DIR"
    print_info ""
    
    if [ -f "$SUMMARY_LOG" ]; then
        print_info "📊 查看摘要报告:"
        print_info "  cat $SUMMARY_LOG"
        print_info ""
        
        # 显示摘要的关键部分
        if command -v bat &> /dev/null; then
            bat "$SUMMARY_LOG"
        else
            cat "$SUMMARY_LOG"
        fi
    fi
}

# 运行主函数
main "$@"

