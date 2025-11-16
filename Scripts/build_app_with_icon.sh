#!/bin/bash

# Nota4 App Builder with Icon
# 构建完整的 macOS 应用程序（带图标）

set -e

echo "🚀 开始构建 Nota4.app..."

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 1. 清理旧的构建
echo -e "${BLUE}📦 清理旧的构建...${NC}"
rm -rf .build/release
rm -rf Nota4.app

# 2. 构建应用
echo -e "${BLUE}🔨 编译项目...${NC}"
swift build -c release

# 3. 创建 .app bundle 结构
echo -e "${BLUE}📁 创建 App Bundle...${NC}"
APP_NAME="Nota4"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# 4. 复制可执行文件
echo -e "${BLUE}📋 复制可执行文件...${NC}"
cp ".build/release/$APP_NAME" "$MACOS_DIR/"
chmod +x "$MACOS_DIR/$APP_NAME"

# 5. 复制图标
echo -e "${BLUE}🎨 设置应用图标...${NC}"
if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "$RESOURCES_DIR/"
    echo "  ✓ 图标已复制"
else
    echo "  ⚠️  未找到图标文件"
fi

# 6. 创建 Info.plist
echo -e "${BLUE}📝 创建 Info.plist...${NC}"
cat > "$CONTENTS_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.nota4.Nota4</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 Nota4. All rights reserved.</string>
</dict>
</plist>
EOF

# 7. 设置文件权限
echo -e "${BLUE}🔐 设置权限...${NC}"
chmod -R 755 "$APP_BUNDLE"

# 8. 显示结果
echo -e "${GREEN}✅ 构建完成！${NC}"
echo ""
echo -e "应用位置: ${BLUE}$(pwd)/$APP_BUNDLE${NC}"
echo -e "应用大小: ${BLUE}$(du -sh "$APP_BUNDLE" | cut -f1)${NC}"
echo ""
echo "运行应用："
echo -e "  ${BLUE}open $APP_BUNDLE${NC}"
echo ""
echo "查看应用信息："
echo -e "  ${BLUE}ls -lh $APP_BUNDLE/Contents/MacOS/${NC}"
echo -e "  ${BLUE}ls -lh $APP_BUNDLE/Contents/Resources/${NC}"

