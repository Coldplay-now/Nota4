import SwiftUI
import AppKit

/// 字体预览选择器
/// 类似 Page/Word 的字体选择器，在列表中直接显示字体样式
struct FontPickerView: NSViewRepresentable {
    @Binding var selectedFont: String
    let fonts: [String]
    let label: String?
    
    init(selectedFont: Binding<String>, fonts: [String], label: String? = nil) {
        self._selectedFont = selectedFont
        self.fonts = fonts
        self.label = label
    }
    
    func makeNSView(context: Context) -> NSPopUpButton {
        let popup = NSPopUpButton()
        popup.target = context.coordinator
        popup.action = #selector(Coordinator.fontChanged(_:))
        
        // 设置固定宽度，确保所有字体选择框宽度一致
        popup.setContentHuggingPriority(.defaultLow, for: .horizontal)
        popup.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // 设置菜单项，每个字体使用对应字体渲染
        updateMenuItems(popup: popup)
        
        // 设置初始选中项
        if let index = fonts.firstIndex(of: selectedFont) {
            popup.selectItem(at: index)
        }
        
        return popup
    }
    
    func updateNSView(_ popup: NSPopUpButton, context: Context) {
        // 如果字体列表或选中字体改变，更新菜单
        let currentSelected = popup.indexOfSelectedItem >= 0 && popup.indexOfSelectedItem < fonts.count
            ? fonts[popup.indexOfSelectedItem]
            : nil
        
        if currentSelected != selectedFont || context.coordinator.lastFonts != fonts {
            updateMenuItems(popup: popup)
            
            // 更新选中项
            if let index = fonts.firstIndex(of: selectedFont) {
                popup.selectItem(at: index)
            }
            context.coordinator.lastFonts = fonts
        }
    }
    
    private func updateMenuItems(popup: NSPopUpButton) {
        popup.removeAllItems()
        
        for fontName in fonts {
            let displayName = EditorPreferences.fontDisplayName(for: fontName)
            
            // 创建菜单项
            let item = NSMenuItem(title: displayName, action: nil, keyEquivalent: "")
            item.representedObject = fontName  // 存储原始字体名称
            
            // 尝试使用对应字体渲染字体名称（类似 Page/Word 的预览效果）
            // 对于 "System"，使用系统字体
            if fontName == "System" {
                let systemFont = NSFont.systemFont(ofSize: 13)
                item.attributedTitle = NSAttributedString(
                    string: displayName,
                    attributes: [
                        .font: systemFont,
                        .foregroundColor: NSColor.labelColor
                    ]
                )
            } else if let font = NSFont(name: fontName, size: 13) {
                // 使用对应字体渲染字体名称，让用户可以直接看到字体样式
                item.attributedTitle = NSAttributedString(
                    string: displayName,
                    attributes: [
                        .font: font,
                        .foregroundColor: NSColor.labelColor
                    ]
                )
            } else {
                // 如果字体加载失败，使用系统字体
                item.attributedTitle = NSAttributedString(
                    string: displayName,
                    attributes: [
                        .font: NSFont.systemFont(ofSize: 13),
                        .foregroundColor: NSColor.labelColor
                    ]
                )
            }
            
            popup.menu?.addItem(item)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedFont: $selectedFont)
    }
    
    class Coordinator: NSObject {
        @Binding var selectedFont: String
        var lastFonts: [String] = []
        
        init(selectedFont: Binding<String>) {
            self._selectedFont = selectedFont
        }
        
        @objc func fontChanged(_ sender: NSPopUpButton) {
            guard let selectedItem = sender.selectedItem,
                  let fontName = selectedItem.representedObject as? String else {
                return
            }
            selectedFont = fontName
        }
    }
}

