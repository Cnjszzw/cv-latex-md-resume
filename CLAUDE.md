# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a LaTeX + Markdown resume generation system. The user edits `src/resume.md` (Markdown) as the single source of truth. AI reads the Markdown content and the LaTeX templates, then generates a compilable `src/resume.tex`. The PDF is built with XeLaTeX — no Pandoc.

## Commands

```bash
make pdf        # Compile PDF (runs xelatex twice, outputs to output/)
make open       # Build and open PDF
make clean      # Remove auxiliary files
make distclean  # Remove all build artifacts including PDF
```

## Architecture

- **`src/resume.md`** — User-edited content source. YAML front matter for personal info, Markdown body for sections.
- **`src/resume.tex`** — AI-generated LaTeX file. Sets personal info variables, then builds the document using macros from the templates. User never edits this directly.
- **`templates/style.sty`** — Visual style package. All colors, fonts, spacing, header layout, section styling, and item formatting are defined here with Chinese comments explaining each parameter. This is where style iteration happens.
- **`templates/cv.latex`** — Structural macros (`\makecvheader`, `\cvsection`, `\cvevent`, `\cvsimple`). Thin layer that delegates all rendering to style.sty.
- **`Makefile`** — Builds from project root. Paths in `resume.tex` are relative to project root (e.g., `\input{templates/style.sty}`).

## Workflow when user requests content or style changes

1. Read `src/resume.md` to understand current content
2. Read `templates/style.sty` and `templates/cv.latex` to understand current styling
3. Generate updated `src/resume.tex` by applying the content to the template macros
4. Run `make pdf` to verify compilation succeeds
5. If style changes are needed, edit `templates/style.sty` directly, then recompile

## Style customization guide

When the user asks to modify the appearance, edit `templates/style.sty`:
- **Colors**: `\definecolor{primary}`, `textdark`, `textgray`, `lightgray` at top of file
- **Fonts**: `\setmainfont` (Latin), `\cjkfont` (CJK) — uses macOS system fonts by default
- **Page margins**: `\geometry` block
- **Photo size**: Width/height in `\makecvheader`'s `\includegraphics`
- **Section header style**: The `\cvsection` macro's tikz drawing
- **Spacing**: `\vspace` values in macros, `\linespread`, `\parskip`

All parameters have Chinese comments in the file explaining what they control.
