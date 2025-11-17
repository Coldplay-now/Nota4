#!/bin/bash

# Nota4 快速运行脚本
# 用于开发时快速测试，支持增量编译

set -e

cd "$(dirname "$0")/.."

# 颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Nota4 快速运行${NC}"

# 1. 增量构建（只编译改变的文件）
echo -e "${BLUE}⚙️  编译中...${NC}"
swift build -c debug 2>&1 | grep -E "Compiling|Linking|Build complete" || true

# 2. 检查是否需要更新应用包
BUILD_DIR="Build"
APP_DIR="$BUILD_DIR/Nota4.app"
EXECUTABLE=".build/debug/Nota4"

# 如果可执行文件比应用包新，或应用包不存在，则更新
if [ ! -d "$APP_DIR" ] || [ "$EXECUTABLE" -nt "$APP_DIR/Contents/MacOS/Nota4" ]; then
    echo -e "${BLUE}📦 更新应用包...${NC}"
    
    mkdir -p "$APP_DIR/Contents/MacOS"
    mkdir -p "$APP_DIR/Contents/Resources"
    
    # 复制可执行文件
    cp "$EXECUTABLE" "$APP_DIR/Contents/MacOS/"
    chmod +x "$APP_DIR/Contents/MacOS/Nota4"
    
    # 复制/更新 Info.plist（如果不存在）
    if [ ! -f "$APP_DIR/Contents/Info.plist" ]; then
        cat > "$APP_DIR/Contents/Info.plist" << 'EOF'
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
	<key>LSUIElement</key>
	<false/>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
	<key>NSHighResolutionCapable</key>
	<true/>
</dict>
</plist>
EOF
    fi
    
    # 复制图标（如果存在）
    if [ -f "Nota4/Nota4/Resources/AppIcon.icns" ]; then
        cp "Nota4/Nota4/Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/"
        echo -e "${BLUE}  ✓ 图标已复制${NC}"
    elif [ -f "Nota4/Resources/AppIcon.icns" ]; then
        cp "Nota4/Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/"
        echo -e "${BLUE}  ✓ 图标已复制${NC}"
    fi
    
    # 复制 Themes 目录
    if [ -d "Nota4/Resources/Themes" ]; then
        echo -e "${BLUE}📁 复制主题资源...${NC}"
        mkdir -p "$APP_DIR/Contents/Resources"
        cp -r "Nota4/Resources/Themes" "$APP_DIR/Contents/Resources/"
        echo -e "${GREEN}✅ 主题资源已复制${NC}"
    fi
else
    echo -e "${GREEN}✅ 应用包已是最新${NC}"
fi

# 3. 关闭旧实例（如果在运行）
pkill -x Nota4 2>/dev/null || true

# 4. 启动应用
echo -e "${GREEN}▶️  启动 Nota4...${NC}"
open "$APP_DIR"

echo -e "${GREEN}✅ 完成！${NC}"
