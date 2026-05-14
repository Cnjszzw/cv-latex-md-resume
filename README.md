# My Resume — LaTeX + Markdown 简历项目

基于 XeLaTeX 的现代化简历生成系统。你只需维护一份 Markdown 文件，即可通过 AI 自动生成排版精美的 PDF 简历。

## 依赖

- **MacTeX**（提供 XeLaTeX 编译器）— 假定已安装
- **make** — macOS 自带

验证依赖：

```bash
xelatex --version
make --version
```

## 快速开始

```bash
# 编译 PDF（首次编译需运行两次以生成目录/引用）
make pdf

# 编译并打开 PDF
make open

# 清理辅助文件
make clean
```

## 使用方法

### 修改简历内容

编辑 `src/resume.md`，使用 Markdown 格式编写你的简历。文件头部使用 YAML 格式设置个人信息：

```yaml
---
name: 张三
title: 高级软件工程师
email: zhangsan@example.com
...
---
```

然后通过 AI 对话，让 AI 读取 `resume.md` 并重新生成 `src/resume.tex`，最后 `make pdf` 编译即可。

### 自定义样式

通过 AI 对话，修改 `templates/style.sty`（视觉样式）或 `templates/cv.latex`（布局框架）。两个文件均有详细的中文注释，标明每个参数的作用。常见的调整包括：

- **配色**：修改 `style.sty` 中的 `primary`、`textdark` 等颜色定义
- **字体**：修改 `style.sty` 中的 `\setmainfont` 和 `\newfontfamily\cjkfont` 设置
- **页边距**：修改 `style.sty` 中的 `\geometry` 参数
- **照片尺寸**：修改 `style.sty` 中 `\makecvheader` 内的 `includegraphics` 尺寸

### 替换证件照

将你的证件照保存为 `assets/photo.png`（或 `.jpg`），然后在 `src/resume.md` 的 YAML 头部确保路径正确。AI 生成 `resume.tex` 时会自动引用。

## 项目结构

```
├── src/
│   ├── resume.md          # 简历内容（Markdown，人类编辑）
│   └── resume.tex         # 自动生成的 LaTeX 文件
├── templates/
│   ├── cv.latex           # 简历框架（变量插槽和章节宏）
│   └── style.sty          # 样式宏包（颜色、字体、布局）
├── assets/
│   └── photo.png          # 证件照
├── fonts/                 # 自定义字体目录（留空，使用系统字体）
├── output/                # 编译产物（PDF 等）
├── Makefile
└── .gitignore
```

## 工作流

1. 人类编辑 `src/resume.md`
2. AI 读取 `src/resume.md` + `templates/` 下的模板
3. AI 生成 `src/resume.tex`
4. `make pdf` 编译生成 PDF

全程不依赖 Pandoc，排版由 LaTeX 模板精确控制。
