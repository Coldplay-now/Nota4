#!/bin/bash

# 从源图片生成 macOS 应用图标集（强制 PNG 格式）

set -e

SOURCE_IMAGE="PRD-doc/20251117-111351.jpg"
OUTPUT_DIR="Assets/Icons"
ICONSET_DIR="$OUTPUT_DIR/Nota4.iconset"

echo "🎨 重新生成应用图标（PNG 格式）..."
echo ""

# 清理并重新创建目录
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

# 生成 1024x1024 主图（PNG 格式）
echo "📐 生成 1024x1024 主图..."
sips -s format png -z 1024 1024 "$SOURCE_IMAGE" --out "$OUTPUT_DIR/icon_1024x1024.png" >/dev/null 2>&1

# 生成各种尺寸的图标（强制 PNG 格式）
echo "📐 生成图标集（PNG 格式）..."

# 16x16
sips -s format png -z 16 16 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null 2>&1
sips -s format png -z 32 32 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null 2>&1

# 32x32
sips -s format png -z 32 32 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null 2>&1
sips -s format png -z 64 64 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null 2>&1

# 128x128
sips -s format png -z 128 128 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null 2>&1
sips -s format png -z 256 256 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null 2>&1

# 256x256
sips -s format png -z 256 256 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null 2>&1
sips -s format png -z 512 512 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null 2>&1

# 512x512
sips -s format png -z 512 512 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null 2>&1
sips -s format png -z 1024 1024 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null 2>&1

echo "✅ 图标集生成完成"
echo ""

# 清除扩展属性
echo "🧹 清除扩展属性..."
xattr -cr "$ICONSET_DIR"
echo "✅ 清理完成"
echo ""

# 验证图标文件格式
echo "🔍 验证图标格式..."
FORMAT=$(sips -g format "$ICONSET_DIR/icon_512x512.png" | tail -1 | awk '{print $2}')
echo "   示例文件格式: $FORMAT"
if [ "$FORMAT" != "png" ]; then
    echo "❌ 错误：文件格式不是 PNG"
    exit 1
fi
echo "✅ 格式验证通过"
echo ""

# 生成 .icns 文件
echo "📦 生成 .icns 文件..."
iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT_DIR/Nota4.icns"

if [ $? -eq 0 ]; then
    echo "✅ .icns 文件生成完成"
    echo ""
    
    # 复制到其他位置
    echo "📋 复制图标文件到其他位置..."
    cp "$OUTPUT_DIR/Nota4.icns" "Resources/AppIcon.icns" 2>/dev/null || true
    cp "$OUTPUT_DIR/Nota4.icns" "Nota4/Resources/AppIcon.icns" 2>/dev/null || true
    echo "✅ 复制完成"
    echo ""
    
    echo "🎉 新图标生成完成！"
    echo ""
    echo "生成的文件："
    echo "  - $OUTPUT_DIR/icon_1024x1024.png"
    echo "  - $ICONSET_DIR/"
    echo "  - $OUTPUT_DIR/Nota4.icns"
    echo ""
    ls -lh "$OUTPUT_DIR/Nota4.icns"
else
    echo "❌ .icns 文件生成失败"
    exit 1
fi

