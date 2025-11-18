#!/bin/bash

# 从源图片生成 macOS 应用图标集
# 输入：源图片
# 输出：完整的 iconset 和 .icns 文件

set -e

SOURCE_IMAGE="$1"
OUTPUT_DIR="Assets/Icons"
ICONSET_DIR="$OUTPUT_DIR/Nota4.iconset"

if [ -z "$SOURCE_IMAGE" ]; then
    echo "❌ 错误：请提供源图片路径"
    echo "用法: $0 <source_image>"
    exit 1
fi

if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "❌ 错误：源图片不存在: $SOURCE_IMAGE"
    exit 1
fi

echo "🎨 开始生成应用图标..."
echo "   源图片: $SOURCE_IMAGE"
echo "   输出目录: $OUTPUT_DIR"
echo ""

# 创建输出目录
mkdir -p "$ICONSET_DIR"

# 生成 1024x1024 主图
echo "📐 生成 1024x1024 主图..."
sips -z 1024 1024 "$SOURCE_IMAGE" --out "$OUTPUT_DIR/icon_1024x1024.png" >/dev/null 2>&1

# 生成各种尺寸的图标
echo "📐 生成图标集（16x16 到 512x512）..."

# 16x16
sips -z 16 16 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null 2>&1
sips -z 32 32 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null 2>&1

# 32x32
sips -z 32 32 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null 2>&1
sips -z 64 64 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null 2>&1

# 128x128
sips -z 128 128 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null 2>&1
sips -z 256 256 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null 2>&1

# 256x256
sips -z 256 256 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null 2>&1
sips -z 512 512 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null 2>&1

# 512x512
sips -z 512 512 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null 2>&1
sips -z 1024 1024 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null 2>&1

echo "✅ 图标集生成完成"
echo ""

# 生成 .icns 文件
echo "📦 生成 .icns 文件..."
iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT_DIR/Nota4.icns"

if [ $? -eq 0 ]; then
    echo "✅ .icns 文件生成完成: $OUTPUT_DIR/Nota4.icns"
    echo ""
    
    # 验证 .icns 文件
    echo "🔍 验证 .icns 文件..."
    iconutil -c iconset "$OUTPUT_DIR/Nota4.icns" -o /tmp/verify_iconset 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ .icns 文件验证通过"
        rm -rf /tmp/verify_iconset
    fi
    
    echo ""
    echo "🎉 图标生成完成！"
    echo ""
    echo "生成的文件："
    echo "  - $OUTPUT_DIR/icon_1024x1024.png (主图)"
    echo "  - $ICONSET_DIR/ (图标集)"
    echo "  - $OUTPUT_DIR/Nota4.icns (macOS 图标)"
    echo ""
else
    echo "❌ .icns 文件生成失败"
    exit 1
fi


