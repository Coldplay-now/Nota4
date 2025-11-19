# 代码块保护功能测试文档

这个文档用于测试代码块中的 `$` 符号是否会被误识别为数学公式。

## Bash 代码块测试

### 测试 1: 环境变量

```bash
#!/bin/bash
# 设置环境变量
export USER_NAME=$USER
export HOME_DIR=$HOME
export PATH=$HOME/bin:$PATH

# 显示变量
echo "User: $USER_NAME"
echo "Home: $HOME_DIR"
echo "Path: $PATH"
```

### 测试 2: Shell 脚本变量

```bash
#!/bin/bash
# 变量赋值和使用
name="John"
age=30
price=$((100 * 2))

echo "Name: $name"
echo "Age: $age"
echo "Price: $$price"
```

### 测试 3: 复杂的 Bash 命令

```bash
#!/bin/bash
# 复杂的变量使用
for file in $HOME/Documents/*.txt; do
    if [ -f "$file" ]; then
        echo "Processing: $file"
        basename=$(basename "$file")
        echo "Basename: $basename"
    fi
done

# 使用 $? 检查命令返回值
ls $HOME/Documents
if [ $? -eq 0 ]; then
    echo "Command succeeded"
fi
```

### 测试 4: 包含多个 $ 符号

```bash
#!/bin/bash
# 多个 $ 符号在同一行
export PATH=$HOME/bin:$HOME/.local/bin:$PATH
export LD_LIBRARY_PATH=$HOME/lib:$LD_LIBRARY_PATH

# 变量嵌套
parent_dir=$HOME
child_dir="$parent_dir/Documents"
echo "Full path: $child_dir"
```

### 测试 5: 特殊变量

```bash
#!/bin/bash
# 特殊变量
echo "Script name: $0"
echo "Arguments: $@"
echo "Argument count: $#"
echo "Last exit code: $?"
echo "Process ID: $$"
echo "Parent process ID: $PPID"
```

## Python 代码块测试（对比）

```python
# Python 代码块中不应该有 $ 符号被误识别
import os

# 使用环境变量
user = os.environ.get('USER')
home = os.environ.get('HOME')
path = os.environ.get('PATH')

print(f"User: {user}")
print(f"Home: {home}")
print(f"Path: {path}")
```

## 数学公式测试（应该正常渲染）

### 行内公式

这是一个行内公式：$x^2 + y^2 = z^2$，应该正常渲染。

另一个行内公式：$E = mc^2$，也应该正常渲染。

### 块级公式

$$
\int_0^1 x^2 dx = \frac{1}{3}
$$

$$
\sum_{i=1}^{n} i = \frac{n(n+1)}{2}
$$

## 混合场景测试

### 场景 1: 代码块和数学公式混合

这是一个行内公式：$f(x) = x^2$。

然后是一个 bash 代码块：

```bash
#!/bin/bash
# 这个代码块中的 $ 不应该被误识别
export VAR=$HOME
echo "Variable: $VAR"
```

然后又是一个数学公式：$\int_0^1 f(x) dx$。

### 场景 2: 代码块中包含类似数学公式的文本

```bash
#!/bin/bash
# 这个代码块中有类似数学公式的文本，但不应该被识别
echo "Price: $100"
echo "Total: $200"
echo "Formula: x^2 + y^2"
```

## 预期结果

- ✅ Bash 代码块中的 `$USER`, `$HOME`, `$PATH` 等应该作为普通文本显示，**不应该**被渲染为数学公式
- ✅ 正常的行内数学公式 `$x^2$` 应该正常渲染
- ✅ 正常的块级数学公式 `$$...$$` 应该正常渲染
- ✅ 代码块和数学公式混合的场景应该都能正确处理





