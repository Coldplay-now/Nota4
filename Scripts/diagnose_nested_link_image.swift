#!/usr/bin/env swift

import Foundation
import Ink

// 测试用例
let testCases = """
# 嵌套链接+图片测试

## 测试1: 普通链接
[GitHub](https://github.com)

## 测试2: 普通图片
![GitHub Logo](https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png)

## 测试3: 嵌套链接+图片（带标题）
[![SwiftUI 教程](https://img.youtube.com/vi/bqu6BquVi2M/0.jpg)](https://www.youtube.com/watch?v=bqu6BquVi2M "SwiftUI Tutorial")

## 测试4: 嵌套链接+图片（不带标题）
[![GitHub Logo](https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png)](https://github.com)

## 测试5: 后续内容
这是测试3和4之后的内容，应该正常显示。

### 子标题测试
- 列表项1
- 列表项2
"""

// 使用 Ink 解析器
let parser = MarkdownParser()
let html = parser.html(from: testCases)

print("=" * 80)
print("生成的 HTML 输出：")
print("=" * 80)
print(html)
print("\n" + "=" * 80)
print("HTML 长度: \(html.count) 字符")
print("=" * 80)

// 检查关键结构
print("\n" + "=" * 80)
print("关键结构检查：")
print("=" * 80)

// 检查测试1（普通链接）
if html.contains("<a href=\"https://github.com\">GitHub</a>") {
    print("✅ 测试1: 普通链接解析正确")
} else {
    print("❌ 测试1: 普通链接解析错误")
    if let range = html.range(of: "GitHub") {
        let context = String(html[range.lowerBound..<html.index(range.upperBound, offsetBy: 50)])
        print("   上下文: \(context)")
    }
}

// 检查测试2（普通图片）
if html.contains("<img") && html.contains("GitHub Logo") {
    print("✅ 测试2: 普通图片解析正确")
} else {
    print("❌ 测试2: 普通图片解析错误")
}

// 检查测试3（嵌套链接+图片，带标题）
let pattern3 = #"<a[^>]*href="https://www\.youtube\.com/watch\?v=bqu6BquVi2M"[^>]*>.*?<img[^>]*>.*?</a>"#
if html.range(of: pattern3, options: .regularExpression) != nil {
    print("✅ 测试3: 嵌套链接+图片（带标题）解析正确")
} else {
    print("❌ 测试3: 嵌套链接+图片（带标题）解析错误")
    // 查找相关部分
    if let range = html.range(of: "SwiftUI") {
        let start = html.index(max(html.startIndex, range.lowerBound), offsetBy: -100)
        let end = html.index(min(html.endIndex, range.upperBound), offsetBy: 200)
        let context = String(html[start..<end])
        print("   上下文: \(context)")
    }
}

// 检查测试4（嵌套链接+图片，不带标题）
let pattern4 = #"<a[^>]*href="https://github\.com"[^>]*>.*?<img[^>]*>.*?</a>"#
if html.range(of: pattern4, options: .regularExpression) != nil {
    print("✅ 测试4: 嵌套链接+图片（不带标题）解析正确")
} else {
    print("❌ 测试4: 嵌套链接+图片（不带标题）解析错误")
}

// 检查测试5（后续内容）
if html.contains("这是测试3和4之后的内容") {
    print("✅ 测试5: 后续内容正常显示")
} else {
    print("❌ 测试5: 后续内容未正常显示")
}

// 检查子标题
if html.contains("<h3>子标题测试</h3>") || html.contains("<h3") && html.contains("子标题测试") {
    print("✅ 子标题: 正常显示")
} else {
    print("❌ 子标题: 未正常显示")
}

// 检查列表
if html.contains("<li>列表项1</li>") || html.contains("<li") && html.contains("列表项1") {
    print("✅ 列表: 正常显示")
} else {
    print("❌ 列表: 未正常显示")
}

print("\n" + "=" * 80)
print("诊断完成")
print("=" * 80)

