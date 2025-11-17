#!/bin/bash

# Nota4 Xcode 应用构建脚本
# 用于在 Xcode 中正确构建可显示窗口的应用

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Nota4 Xcode 应用构建${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

cd "$PROJECT_ROOT"

# 1. 清理旧构建
echo -e "${YELLOW}1. 清理旧构建...${NC}"
swift package clean
rm -rf .build
rm -rf Build

# 2. 使用 xcodebuild 构建
echo -e "${YELLOW}2. 生成 Xcode 项目...${NC}"
swift package generate-xcodeproj || true

# 3. 构建应用
echo -e "${YELLOW}3. 构建应用...${NC}"

# 使用 swift build 但添加正确的链接器标志
swift build \
    -c debug \
    -Xlinker -sectcreate \
    -Xlinker __TEXT \
    -Xlinker __info_plist \
    -Xlinker "Nota4/Resources/Info.plist"

# 4. 创建应用包结构
echo -e "${YELLOW}4. 创建应用包...${NC}"

BUILD_DIR="$PROJECT_ROOT/Build"
APP_DIR="$BUILD_DIR/Nota4.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# 5. 复制可执行文件
echo -e "${YELLOW}5. 复制可执行文件...${NC}"
cp ".build/debug/Nota4" "$MACOS_DIR/"
chmod +x "$MACOS_DIR/Nota4"

# 6. 创建 Info.plist
echo -e "${YELLOW}6. 创建 Info.plist...${NC}"
cat > "$CONTENTS_DIR/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>Nota4</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
	<key>CFBundleIdentifier</key>
	<string>com.nota4.Nota4</string>
	<key>CFBundleName</key>
	<string>Nota4</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>14.0</string>
	<key>NSHumanReadableCopyright</key>
	<string>Copyright © 2025 Nota4. All rights reserved.</string>
	<key>LSApplicationCategoryType</key>
	<string>public.app-category.productivity</string>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
	<key>LSUIElement</key>
	<false/>
	<key>NSHighResolutionCapable</key>
	<true/>
</dict>
</plist>
EOF

# 7. 复制图标
echo -e "${YELLOW}7. 复制应用图标...${NC}"
if [ -f "$PROJECT_ROOT/Nota4/Nota4/Resources/AppIcon.icns" ]; then
    cp "$PROJECT_ROOT/Nota4/Nota4/Resources/AppIcon.icns" "$RESOURCES_DIR/"
    echo -e "${GREEN}✓ 图标已复制${NC}"
elif [ -f "$PROJECT_ROOT/Resources/AppIcon.icns" ]; then
    cp "$PROJECT_ROOT/Resources/AppIcon.icns" "$RESOURCES_DIR/"
    echo -e "${GREEN}✓ 图标已复制${NC}"
else
    echo -e "${YELLOW}⚠ 未找到应用图标${NC}"
fi

# 8. 设置应用权限
echo -e "${YELLOW}8. 设置权限...${NC}"
chmod -R 755 "$APP_DIR"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ 构建完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}应用位置:${NC}"
echo -e "  $APP_DIR"
echo ""
echo -e "${BLUE}运行应用:${NC}"
echo -e "  open $APP_DIR"
echo ""

