# ============================================================
# Makefile — 简历项目构建脚本
# ============================================================

# TeX 二进制路径（macOS + MacTeX 默认安装位置）
TEXPATH = /Library/TeX/texbin
# 编译器：XeLaTeX（支持中文和系统字体）
TEX = $(TEXPATH)/xelatex
# 编译时确保 TeX 工具在 PATH 中（某些宏包需要调用辅助工具）
export PATH := $(TEXPATH):$(PATH)
# 编译选项：-interaction=nonstopmode 遇到错误不停止
#          -output-directory=output 输出到 output/ 目录
TEXFLAGS = -interaction=nonstopmode -output-directory=output
# 主文件
MAIN = src/resume.tex
# 输出 PDF
PDF = output/resume.pdf

# 默认目标：编译 PDF
.PHONY: pdf
pdf:
	@mkdir -p output
	$(TEX) $(TEXFLAGS) $(MAIN)
	$(TEX) $(TEXFLAGS) $(MAIN)
	@echo "✅ PDF 已生成：$(PDF)"

# 清理辅助文件
.PHONY: clean
clean:
	@rm -f output/*.aux output/*.log output/*.out output/*.toc
	@rm -f output/*.synctex.gz output/*.fls output/*.fdb_latexmk
	@echo "✅ 辅助文件已清理"

# 清理所有编译产物（包括 PDF）
.PHONY: distclean
distclean: clean
	@rm -f $(PDF)
	@echo "✅ 编译产物已全部清理"

# 打开生成的 PDF
.PHONY: open
open: pdf
	open $(PDF)

# 帮助信息
.PHONY: help
help:
	@echo "可用命令："
	@echo "  make pdf        — 编译生成 PDF"
	@echo "  make clean      — 清理辅助文件"
	@echo "  make distclean  — 清理所有编译产物（含 PDF）"
	@echo "  make open       — 编译并打开 PDF"
