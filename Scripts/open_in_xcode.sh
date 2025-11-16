#!/bin/bash

# 脚本名称: open_in_xcode.sh
# 描述: 在 Xcode 中打开 Nota4 项目

set -e

PROJECT_ROOT="$(dirname "$0")/.."
PACKAGE_FILE="$PROJECT_ROOT/Package.swift"

echo "📦 在 Xcode 中打开 Nota4 项目..."
open "$PACKAGE_FILE"

echo "✅ 完成！"
echo ""
echo "🎯 Xcode 调试提示："
echo "  1. 选择 Nota4 scheme"
echo "  2. 目标选择 My Mac"
echo "  3. 按 Cmd+R 运行应用"
echo "  4. 按 Cmd+Shift+Y 显示控制台"
echo ""
echo "📖 详细调试指南: Docs/XCODE_DEBUG_GUIDE.md"

