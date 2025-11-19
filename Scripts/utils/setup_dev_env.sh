#!/bin/bash

# Nota4 开发环境设置脚本
# 用途：初始化开发环境，安装依赖

set -e

echo "🚀 Nota4 开发环境设置开始..."

# 检查 Xcode 是否安装
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 错误：未找到 Xcode，请先安装 Xcode 15.0+"
    exit 1
fi

echo "✅ Xcode 已安装"

# 检查 Xcode 版本
XCODE_VERSION=$(xcodebuild -version | head -n 1 | awk '{print $2}')
echo "📦 Xcode 版本: $XCODE_VERSION"

# 检查 Swift 版本
SWIFT_VERSION=$(swift --version | head -n 1)
echo "📦 Swift 版本: $SWIFT_VERSION"

# 切换到项目根目录
cd "$(dirname "$0")/../.."

# 解析 SPM 依赖
echo "📥 解析 Swift Package 依赖..."
swift package resolve

# 构建项目（检查是否有错误）
echo "🔨 构建项目..."
swift build

echo ""
echo "✅ 开发环境设置完成！"
echo ""
echo "📝 下一步："
echo "   1. 运行调试构建: ./Scripts/build/build_debug.sh"
echo "   2. 运行测试: ./Scripts/test/run_unit_tests.sh"
echo ""













