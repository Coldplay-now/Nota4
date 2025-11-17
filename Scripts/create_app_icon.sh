#!/bin/bash

# Nota4 App Icon Creator
# 将 JPG/PNG 图片转换为 macOS .icns 图标文件
# 使用方法: ./create_app_icon.sh <input_image> [output_path]

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查输入参数
if [ $# -lt 1 ]; then
    echo -e "${RED}错误: 请提供输入图片路径${NC}"
    echo "使用方法: $0 <input_image> [output_path]"
    echo "示例: $0 logo.jpg Nota4/Nota4/Resources/AppIcon.icns"
    exit 1
fi

INPUT_IMAGE="$1"
OUTPUT_ICNS="${2:-Nota4/Nota4/Resources/AppIcon.icns}"

# 检查输入文件是否存在
if [ ! -f "$INPUT_IMAGE" ]; then
    echo -e "${RED}错误: 输入文件不存在: $INPUT_IMAGE${NC}"
    exit 1
fi

# 获取脚本所在目录的父目录（项目根目录）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 切换到项目根目录
cd "$PROJECT_ROOT"

# 转换为绝对路径
if [[ "$INPUT_IMAGE" != /* ]]; then
    # 如果是相对路径，先尝试相对于当前目录，再尝试相对于项目根目录
    if [ -f "$INPUT_IMAGE" ]; then
        INPUT_IMAGE="$(cd "$(dirname "$INPUT_IMAGE")" && pwd)/$(basename "$INPUT_IMAGE")"
    elif [ -f "$PROJECT_ROOT/$INPUT_IMAGE" ]; then
        INPUT_IMAGE="$(cd "$(dirname "$PROJECT_ROOT/$INPUT_IMAGE")" && pwd)/$(basename "$INPUT_IMAGE")"
    else
        echo -e "${RED}错误: 找不到输入文件: $INPUT_IMAGE${NC}"
        exit 1
    fi
fi

if [[ "$OUTPUT_ICNS" != /* ]]; then
    OUTPUT_ICNS="$PROJECT_ROOT/$OUTPUT_ICNS"
fi

# 规范化路径（移除多余的 ./ 和 ..）
OUTPUT_ICNS="$(cd "$(dirname "$OUTPUT_ICNS")" && pwd)/$(basename "$OUTPUT_ICNS")"

# 创建临时 iconset 目录
ICONSET_DIR="${OUTPUT_ICNS%.icns}.iconset"
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

echo -e "${BLUE}🎨 开始创建应用图标...${NC}"
echo -e "输入文件: ${BLUE}$INPUT_IMAGE${NC}"
echo -e "输出文件: ${BLUE}$OUTPUT_ICNS${NC}"
echo ""

# macOS 图标所需的所有尺寸
# 格式: <filename> <size>
declare -a SIZES=(
    "icon_16x16.png 16"
    "icon_16x16@2x.png 32"
    "icon_32x32.png 32"
    "icon_32x32@2x.png 64"
    "icon_128x128.png 128"
    "icon_128x128@2x.png 256"
    "icon_256x256.png 256"
    "icon_256x256@2x.png 512"
    "icon_512x512.png 512"
    "icon_512x512@2x.png 1024"
)

echo -e "${BLUE}📐 生成不同尺寸的图标...${NC}"

# 使用 sips 转换图片
for item in "${SIZES[@]}"; do
    read -r filename size <<< "$item"
    output_path="$ICONSET_DIR/$filename"
    
    echo -e "  生成 ${size}x${size} -> $filename"
    
    # 使用 sips 转换图片（保持宽高比，居中裁剪，强制 PNG 格式）
    sips -s format png -z "$size" "$size" "$INPUT_IMAGE" --out "$output_path" > /dev/null 2>&1
    
    if [ ! -f "$output_path" ]; then
        echo -e "${RED}错误: 无法生成 $filename${NC}"
        rm -rf "$ICONSET_DIR"
        exit 1
    fi
done

echo ""
echo -e "${BLUE}🔨 生成 .icns 文件...${NC}"

# 使用 iconutil 生成 .icns 文件
iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT_ICNS"

if [ ! -f "$OUTPUT_ICNS" ]; then
    echo -e "${RED}错误: 无法生成 .icns 文件${NC}"
    rm -rf "$ICONSET_DIR"
    exit 1
fi

# 清理临时目录
rm -rf "$ICONSET_DIR"

# 显示结果
ICON_SIZE=$(du -h "$OUTPUT_ICNS" | cut -f1)
echo ""
echo -e "${GREEN}✅ 图标创建成功！${NC}"
echo -e "文件位置: ${BLUE}$OUTPUT_ICNS${NC}"
echo -e "文件大小: ${BLUE}$ICON_SIZE${NC}"
echo ""
echo -e "${YELLOW}提示:${NC}"
echo -e "  1. 图标已保存到: ${BLUE}$OUTPUT_ICNS${NC}"
echo -e "  2. 重新构建应用后，新图标将生效"
echo -e "  3. 如果图标未更新，请清除应用缓存:"
echo -e "     ${BLUE}rm -rf ~/Library/Caches/com.nota4.Nota4${NC}"

