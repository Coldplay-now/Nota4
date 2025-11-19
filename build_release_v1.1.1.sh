#!/bin/bash

# Nota4 v1.1.1 发布脚本（新图标版本）

set -e

echo "🚀 Nota4 v1.1.1 发布流程（新图标版本）"
echo ""

# 配置信息
APP_NAME="Nota4"
BUNDLE_ID="com.nota4.Nota4"
DEVELOPER_ID="Developer ID Application: Xiaotian LIU (3G34A92J6L)"
APPLE_ID="lxiaotian@gmail.com"
TEAM_ID="3G34A92J6L"
APP_PASSWORD="fugy-ntzw-gzua-rpdr"
VERSION="1.1.1"

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
echo "  架构: arm64"
echo "  更新: 新图标设计"
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

echo "   ✓ 二进制文件已复制"

# 创建 Resources Bundle
if [ -d "Nota4/Resources" ]; then
    BUNDLE_NAME="Nota4_Nota4.bundle"
    BUNDLE_PATH="$APP_PATH/Contents/Resources/$BUNDLE_NAME"
    
    echo "   ✓ 创建 Resources Bundle"
    mkdir -p "$BUNDLE_PATH"
    cp -R Nota4/Resources/* "$BUNDLE_PATH/" 2>/dev/null || true
    
    # 创建 Bundle Info.plist
    cat > "$BUNDLE_PATH/Info.plist" << 'BUNDLE_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleIdentifier</key>
    <string>com.nota4.Nota4.resources</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Nota4_Nota4</string>
    <key>CFBundlePackageType</key>
    <string>BNDL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.1.1</string>
    <key>CFBundleVersion</key>
    <string>3</string>
</dict>
</plist>
BUNDLE_EOF
fi

# 创建 Info.plist
cat > "$APP_PATH/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
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
    <string>3</string>
    <key>CFBundleIconFile</key>
    <string>Nota4</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2024-2025. All rights reserved.</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>nota</string>
            </array>
            <key>CFBundleTypeName</key>
            <string>Nota Document</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>LSHandlerRank</key>
            <string>Owner</string>
        </dict>
        <dict>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>md</string>
                <string>markdown</string>
            </array>
            <key>CFBundleTypeName</key>
            <string>Markdown Document</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
        </dict>
    </array>
</dict>
</plist>
EOF

# 复制新图标
echo "   ✓ 使用新图标: Assets/Icons/Nota4.icns"
cp "Assets/Icons/Nota4.icns" "$APP_PATH/Contents/Resources/Nota4.icns"

echo "✅ Nota4.app 结构创建完成"
echo ""

# ============================================
# 步骤 2: 签名应用
# ============================================
echo "✍️  2. 签名应用..."
codesign --force --deep \
  --sign "$DEVELOPER_ID" \
  --options runtime \
  --timestamp \
  "$APP_PATH"

codesign -vvv --deep --strict "$APP_PATH"
echo "✅ 应用签名完成"
echo ""

# ============================================
# 步骤 3: 创建 DMG
# ============================================
echo "💿 3. 创建 DMG..."
APP_SIZE=$(du -sm "$APP_PATH" | cut -f1)
DMG_SIZE=$((APP_SIZE + 30))

hdiutil create \
  -size ${DMG_SIZE}m \
  -fs HFS+ \
  -volname "$APP_NAME Installer" \
  "$TEMP_DMG"

mkdir -p "$MOUNT_POINT"
hdiutil attach "$TEMP_DMG" -mountpoint "$MOUNT_POINT"

cp -R "$APP_PATH" "$MOUNT_POINT/"
ln -s /Applications "$MOUNT_POINT/Applications"

hdiutil detach "$MOUNT_POINT"

hdiutil convert "$TEMP_DMG" \
  -format UDZO \
  -o "$DMG_PATH"

rm "$TEMP_DMG"
rmdir "$MOUNT_POINT" 2>/dev/null || true

echo "✅ DMG 创建完成"
echo ""

# ============================================
# 步骤 4: 签名 DMG
# ============================================
echo "✍️  4. 签名 DMG..."
codesign --sign "$DEVELOPER_ID" \
  --timestamp \
  "$DMG_PATH"

codesign -vvv "$DMG_PATH"
echo "✅ DMG 签名完成"
echo ""

# ============================================
# 步骤 5: 公证 DMG
# ============================================
echo "📮 5. 提交公证请求..."
echo "⏳ 这可能需要几分钟..."
echo ""

xcrun notarytool submit "$DMG_PATH" \
  --apple-id "$APPLE_ID" \
  --team-id "$TEAM_ID" \
  --password "$APP_PASSWORD" \
  --wait

if [ $? -ne 0 ]; then
    echo "❌ 公证失败"
    exit 1
fi

echo "✅ 公证成功"
echo ""

# ============================================
# 步骤 6: Staple
# ============================================
echo "📎 6. 附加公证票据..."
xcrun stapler staple "$DMG_PATH"

if [ $? -ne 0 ]; then
    echo "❌ Stapling 失败"
    exit 1
fi

echo "✅ 公证票据已附加"
echo ""

# ============================================
# 步骤 7: 最终验证
# ============================================
echo "🔍 7. 最终验证..."
codesign -vvv "$DMG_PATH"
spctl -a -vvv -t install "$DMG_PATH"

echo "✅ 所有验证通过"
echo ""

# ============================================
# 完成
# ============================================
echo "🎉 ============================================"
echo "🎉  Nota4 v${VERSION} 构建完成！"
echo "🎉 ============================================"
echo ""
echo "📦 安装包信息："
echo "   文件名: $DMG_NAME"
echo "   路径: $DMG_PATH"
echo "   大小: $(du -h "$DMG_PATH" | cut -f1)"
echo "   版本: $VERSION (Build 3)"
echo "   更新: 全新图标设计"
echo ""
echo "✅ 状态:"
echo "   ✓ 应用已签名"
echo "   ✓ DMG 已签名"
echo "   ✓ 已通过 Apple 公证"
echo "   ✓ 公证票据已附加"
echo "   ✓ 已通过 Gatekeeper 验证"
echo ""
echo "🚀 可以分发了！"
echo ""





