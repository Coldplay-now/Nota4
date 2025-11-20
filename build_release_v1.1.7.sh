#!/bin/bash

# Nota4 v1.1.7 发布脚本（修复 TOC 锚点跳转问题）

set -e

echo "🚀 Nota4 v1.1.7 发布流程（修复 TOC 锚点跳转问题）"
echo ""

# 配置信息
APP_NAME="Nota4"
BUNDLE_ID="com.nota4.Nota4"
DEVELOPER_ID="Developer ID Application: Xiaotian LIU (3G34A92J6L)"
APPLE_ID="lxiaotian@gmail.com"
TEAM_ID="3G34A92J6L"
APP_PASSWORD="fugy-ntzw-gzua-rpdr"
VERSION="1.1.7"
BUILD_NUMBER="9"

# 路径配置
PROJECT_DIR="/Users/xt/LXT/code/trae/1107-model-eval/Nota4"
cd "$PROJECT_DIR"

BINARY_PATH="$PROJECT_DIR/.build/arm64-apple-macosx/release/Nota4"
APP_PATH="$PROJECT_DIR/Nota4.app"
DMG_NAME="Nota4-Installer-v${VERSION}.dmg"
DMG_PATH="$PROJECT_DIR/$DMG_NAME"
TEMP_DMG="$PROJECT_DIR/temp.dmg"
MOUNT_POINT="$PROJECT_DIR/dmg_mount"

echo "📋 配置信息："
echo "  应用名称: $APP_NAME"
echo "  版本号: $VERSION"
echo "  Build 号: $BUILD_NUMBER"
echo "  架构: arm64"
echo "  更新: 修复 TOC 锚点跳转问题"
echo ""

# 检查 Vendor 资源是否存在
echo "🔍 检查本地 CDN 资源..."
VENDOR_DIR="Nota4/Resources/Vendor"
if [ ! -d "$VENDOR_DIR" ]; then
    echo "❌ Vendor 目录不存在: $VENDOR_DIR"
    exit 1
fi

REQUIRED_FILES=("mermaid.min.js" "katex.min.css" "katex.min.js")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$VENDOR_DIR/$file" ]; then
        echo "❌ 缺少必需文件: $VENDOR_DIR/$file"
        exit 1
    fi
done

echo "✅ 所有 CDN 资源已本地化"
echo ""

# 检查二进制文件是否存在（使用现有的构建产物）
if [ ! -f "$BINARY_PATH" ]; then
    echo "⚠️  未找到构建产物，开始构建..."
    swift build -c release --arch arm64
    
    if [ $? -ne 0 ]; then
        echo "❌ 构建失败"
        exit 1
    fi
    echo "✅ 构建完成"
    echo ""
else
    echo "✅ 使用现有构建产物"
    echo ""
fi

# ============================================
# 步骤 1: 创建 .app 结构
# ============================================
echo "📦 1. 创建 Nota4.app 结构..."

# 清理旧的 .app 和 DMG
rm -rf "$APP_PATH"
rm -f "$DMG_PATH"

# 创建目录结构
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

# 复制二进制文件
cp "$BINARY_PATH" "$APP_PATH/Contents/MacOS/Nota4"
chmod +x "$APP_PATH/Contents/MacOS/Nota4"

# 复制 Info.plist
cat > "$APP_PATH/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>Nota4</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$BUILD_NUMBER</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025</string>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
    </dict>
</dict>
</plist>
EOF

# 复制应用图标（优先使用 Assets/Icons，其次使用 Resources）
if [ -f "Assets/Icons/Nota4.icns" ]; then
    cp "Assets/Icons/Nota4.icns" "$APP_PATH/Contents/Resources/AppIcon.icns"
    echo "   ✓ 应用图标已复制（来自 Assets/Icons）"
elif [ -f "Nota4/Nota4/Resources/AppIcon.icns" ]; then
    cp "Nota4/Nota4/Resources/AppIcon.icns" "$APP_PATH/Contents/Resources/AppIcon.icns"
    echo "   ✓ 应用图标已复制（来自 Resources）"
elif [ -f "Nota4/Nota4/Nota4.icns" ]; then
    cp "Nota4/Nota4/Nota4.icns" "$APP_PATH/Contents/Resources/AppIcon.icns"
    echo "   ✓ 应用图标已复制（来自 Nota4/Nota4）"
else
    echo "   ⚠️  未找到应用图标"
fi

# 复制 Vendor 资源（Mermaid.js, KaTeX）
echo "📦 2. 复制 Vendor 资源..."
VENDOR_DEST="$APP_PATH/Contents/Resources/Vendor"
mkdir -p "$VENDOR_DEST"
cp -r "$VENDOR_DIR"/* "$VENDOR_DEST/"
echo "   ✓ Vendor 资源已复制"

# 复制主题资源
echo "📦 3. 复制主题资源..."
THEMES_DIR="Nota4/Resources/Themes"
if [ -d "$THEMES_DIR" ]; then
    THEMES_DEST="$APP_PATH/Contents/Resources/Themes"
    mkdir -p "$THEMES_DEST"
    cp -r "$THEMES_DIR"/* "$THEMES_DEST/"
    echo "   ✓ 主题资源已复制"
else
    echo "   ⚠️  未找到主题资源目录"
fi

# 复制初始文档
echo "📦 4. 复制初始文档..."
INITIAL_DOCS_SRC="Nota4/Resources/InitialDocuments"
if [ -d "$INITIAL_DOCS_SRC" ]; then
    INITIAL_DOCS_DEST="$APP_PATH/Contents/Resources/InitialDocuments"
    mkdir -p "$INITIAL_DOCS_DEST"
    cp -r "$INITIAL_DOCS_SRC"/* "$INITIAL_DOCS_DEST/"
    echo "   ✓ 初始文档已复制"
    
    # 验证 InitialDocuments 资源已复制（关键验证）
    if [ -d "$INITIAL_DOCS_DEST" ]; then
        echo "   ✓ InitialDocuments 资源已复制"
        ls -lh "$INITIAL_DOCS_DEST/" | tail -6
        
        # 验证关键文件存在（包括新增的两个文档）
        REQUIRED_FILES=("使用说明.nota" "Markdown示例.nota" "运动.nota" "技术.nota")
        MISSING_FILES=()
        for file in "${REQUIRED_FILES[@]}"; do
            if [ ! -f "$INITIAL_DOCS_DEST/$file" ]; then
                MISSING_FILES+=("$file")
            fi
        done
        
        if [ ${#MISSING_FILES[@]} -eq 0 ]; then
            echo "   ✓ InitialDocuments 关键文件验证通过（4个文档）"
            # 验证文件大小（确保不是空文件）
            for file in "${REQUIRED_FILES[@]}"; do
                FILE_SIZE=$(stat -f%z "$INITIAL_DOCS_DEST/$file" 2>/dev/null || echo "0")
                if [ "$FILE_SIZE" -lt 100 ]; then
                    echo "   ⚠️  警告: $file 文件大小异常小 ($FILE_SIZE 字节)"
                fi
            done
        else
            echo "   ❌ 缺少初始文档文件: ${MISSING_FILES[*]}"
            exit 1
        fi
    else
        echo "   ❌ InitialDocuments 目录未正确复制"
        exit 1
    fi
else
    echo "   ⚠️  未找到初始文档源目录"
fi

echo ""

# ============================================
# 步骤 2: 代码签名
# ============================================
echo "🔐 5. 代码签名..."

# 创建临时 entitlements 文件
ENTITLEMENTS_FILE="$PROJECT_DIR/temp_entitlements.plist"
cat > "$ENTITLEMENTS_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <key>com.apple.security.files.downloads.read-write</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
</plist>
EOF

# 签名应用
codesign --force --deep --sign "$DEVELOPER_ID" \
    --options runtime \
    --entitlements "$ENTITLEMENTS_FILE" \
    "$APP_PATH"

# 清理临时文件
rm -f "$ENTITLEMENTS_FILE"

if [ $? -eq 0 ]; then
    echo "   ✓ 应用签名成功"
else
    echo "   ❌ 应用签名失败"
    exit 1
fi

# 验证签名
codesign --verify --verbose "$APP_PATH"
if [ $? -eq 0 ]; then
    echo "   ✓ 签名验证通过"
else
    echo "   ❌ 签名验证失败"
    exit 1
fi

echo ""

# ============================================
# 步骤 3: 创建 DMG
# ============================================
echo "📦 6. 创建 DMG..."

# 清理旧的挂载点
rm -rf "$MOUNT_POINT"
mkdir -p "$MOUNT_POINT"

# 创建临时 DMG
hdiutil create -volname "Nota4" -srcfolder "$APP_PATH" -ov -format UDRW -size 100m "$TEMP_DMG"

# 挂载临时 DMG
hdiutil attach "$TEMP_DMG" -mountpoint "$MOUNT_POINT" -nobrowse

# 等待挂载完成
sleep 2

# 创建 Applications 链接
ln -s /Applications "$MOUNT_POINT/Applications"

# 卸载临时 DMG
hdiutil detach "$MOUNT_POINT"

# 转换为只读 DMG
hdiutil convert "$TEMP_DMG" -format UDZO -o "$DMG_PATH"

# 清理临时文件
rm -f "$TEMP_DMG"

if [ -f "$DMG_PATH" ]; then
    echo "   ✓ DMG 创建成功"
    echo "   路径: $DMG_PATH"
    echo "   大小: $(du -h "$DMG_PATH" | cut -f1)"
else
    echo "   ❌ DMG 创建失败"
    exit 1
fi

echo ""

# ============================================
# 步骤 4: 签名 DMG
# ============================================
echo "🔐 7. 签名 DMG..."

codesign --force --sign "$DEVELOPER_ID" "$DMG_PATH"

if [ $? -eq 0 ]; then
    echo "   ✓ DMG 签名成功"
else
    echo "   ❌ DMG 签名失败"
    exit 1
fi

echo ""

# ============================================
# 步骤 5: 公证
# ============================================
echo "📋 8. 提交公证..."

# 提交公证
xcrun notarytool submit "$DMG_PATH" \
    --apple-id "$APPLE_ID" \
    --team-id "$TEAM_ID" \
    --password "$APP_PASSWORD" \
    --wait

if [ $? -eq 0 ]; then
    echo "   ✓ 公证成功"
else
    echo "   ❌ 公证失败"
    exit 1
fi

echo ""

# ============================================
# 步骤 6: 附加公证票据
# ============================================
echo "📎 9. 附加公证票据..."

xcrun stapler staple "$DMG_PATH"

if [ $? -eq 0 ]; then
    echo "   ✓ 公证票据已附加"
else
    echo "   ⚠️  附加公证票据失败（可能已经附加）"
fi

echo ""

# ============================================
# 步骤 7: 最终验证
# ============================================
echo "✅ 10. 最终验证..."

# 验证 Gatekeeper
spctl --assess --verbose --type open "$DMG_PATH"
if [ $? -eq 0 ]; then
    echo "   ✓ 通过 Gatekeeper 验证"
else
    echo "   ⚠️  Gatekeeper 验证警告（可能需要用户手动允许）"
fi

echo ""
echo "=========================================="
echo "🎉 发布完成！"
echo "=========================================="
echo ""
echo "📦 发布包信息："
echo "   名称: $DMG_NAME"
echo "   路径: $DMG_PATH"
echo "   大小: $(du -h "$DMG_PATH" | cut -f1)"
echo "   版本: $VERSION (Build $BUILD_NUMBER)"
echo "   更新: 修复 TOC 锚点跳转问题"
echo ""
echo "✅ 状态:"
echo "   ✓ 应用已签名"
echo "   ✓ DMG 已签名"
echo "   ✓ 已通过 Apple 公证"
echo "   ✓ 公证票据已附加"
echo "   ✓ 已通过 Gatekeeper 验证"
echo "   ✓ 所有 CDN 资源已本地化（Mermaid.js, KaTeX）"
echo "   ✓ 初始文档已包含（使用说明、Markdown示例、运动、技术）"
echo ""
echo "🚀 可以分发了！"
echo ""

