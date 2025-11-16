# Nota4 Makefile

.PHONY: run build test clean help

# 默认目标
.DEFAULT_GOAL := help

## 快速运行（开发时使用）
run:
	@./Scripts/quick_run.sh

## 完整构建（发布时使用）
build:
	@./Scripts/build_xcode_app.sh

## 运行测试
test:
	@swift test

## 运行测试并监控
test-watch:
	@./Scripts/monitor_xcode_debug.sh --build

## 清理构建产物
clean:
	@echo "🧹 清理..."
	@swift package clean
	@rm -rf .build Build
	@echo "✅ 清理完成"

## 监控日志
logs:
	@./Scripts/watch_app_logs.sh

## 格式化代码（如果有 swift-format）
format:
	@if command -v swift-format >/dev/null 2>&1; then \
		swift-format -i -r Nota4; \
		echo "✅ 代码已格式化"; \
	else \
		echo "⚠️  swift-format 未安装"; \
	fi

## 帮助信息
help:
	@echo "Nota4 开发命令"
	@echo ""
	@echo "使用方法: make [命令]"
	@echo ""
	@echo "命令:"
	@echo "  run          - 快速编译并运行应用（开发时用）⭐"
	@echo "  build        - 完整构建应用包（发布时用）"
	@echo "  test         - 运行单元测试"
	@echo "  test-watch   - 运行测试并监控"
	@echo "  clean        - 清理构建产物"
	@echo "  logs         - 启动日志监控"
	@echo "  format       - 格式化代码"
	@echo "  help         - 显示此帮助信息"
	@echo ""
	@echo "快速开始:"
	@echo "  make run     # 运行应用"
	@echo "  make test    # 运行测试"
	@echo ""

