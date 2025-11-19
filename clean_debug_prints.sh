#!/bin/bash

# 清理调试打印代码（保留错误日志）

set -e

echo "🧹 清理调试打印代码..."
echo ""

PROJECT_DIR="/Users/xt/LXT/code/trae/1107-model-eval/Nota4"
cd "$PROJECT_DIR"

# 需要清理的文件列表
FILES_TO_CLEAN=(
    "Nota4/App/AppFeature.swift"
    "Nota4/Features/Editor/EditorFeature.swift"
    "Nota4/Features/NoteList/NoteListFeature.swift"
    "Nota4/Features/Editor/MarkdownTextEditor.swift"
    "Nota4/Features/Preferences/SettingsFeature.swift"
    "Nota4/Services/MarkdownRenderer.swift"
    "Nota4/Services/NoteRepository.swift"
    "Nota4/Services/ThemeManager.swift"
    "Nota4/Services/ImageCache.swift"
    "Nota4/Services/ImageManager.swift"
    "Nota4/Services/PreferencesStorage.swift"
    "Nota4/Services/NotaFileManager.swift"
    "Nota4/Services/InitialDocumentsService.swift"
    "Nota4/Features/Editor/MarkdownPreview.swift"
    "Nota4/Views/Components/WebViewWrapper.swift"
    "Nota4/Services/ImportService.swift"
    "Nota4/Services/ExportService.swift"
    "Nota4/Features/Sidebar/SidebarFeature.swift"
)

# 清理调试打印（保留错误日志）
# 移除包含 emoji 的 print 语句（🔵 🟢 🟡 ✅ 📝 📚 等），但保留 ❌ 错误日志
for file in "${FILES_TO_CLEAN[@]}"; do
    if [ -f "$file" ]; then
        echo "  处理: $file"
        # 使用 sed 移除调试 print，但保留错误日志
        # 移除包含特定 emoji 的 print 行（除了 ❌）
        sed -i '' \
            -e '/print("🔵/d' \
            -e '/print("🟢/d' \
            -e '/print("🟡/d' \
            -e '/print("✅ \[/d' \
            -e '/print("📝 \[/d' \
            -e '/print("📚 \[/d' \
            -e '/print("📁 \[/d' \
            -e '/print("📷 \[/d' \
            -e '/print("🖼️ \[/d' \
            -e '/print("🎨 \[/d' \
            -e '/print("🔄 \[/d' \
            -e '/print("⚙️ \[/d' \
            -e '/print("📐 \[/d' \
            -e '/print("📊 \[/d' \
            -e '/print("📋 \[/d' \
            -e '/print("🔍 \[/d' \
            -e '/print("⏭️ \[/d' \
            -e '/print("🎉 \[/d' \
            -e '/print("📤 \[/d' \
            -e '/print("📁 \[/d' \
            -e '/print("🗑️ \[/d' \
            -e '/print("💾 \[/d' \
            -e '/print("📖 \[/d' \
            -e '/print("📄 \[/d' \
            -e '/print("♻️ \[/d' \
            -e '/print("💣 \[/d' \
            -e '/print("🧹 \[/d' \
            -e '/print("⚠️ \[RENDER\]/d' \
            -e '/print("⚠️ \[IMAGE\]/d' \
            -e '/print("⚠️ \[PREFS\]/d' \
            "$file" 2>/dev/null || true
    fi
done

# 特殊处理 AppDelegate.swift（保留退出日志，但简化）
if [ -f "Nota4/App/AppDelegate.swift" ]; then
    echo "  处理: Nota4/App/AppDelegate.swift"
    # 简化退出日志
    sed -i '' \
        -e 's/print("🔴 \[EXIT\].*")/\/\/ Debug: App terminating/g' \
        "Nota4/App/AppDelegate.swift" 2>/dev/null || true
fi

echo "✅ 调试打印代码清理完成"
echo ""


