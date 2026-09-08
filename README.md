<div align="center">

# neovim 中文翻译版

**[中文版] neovim — 专注可扩展性与易用性的 Vim 分支现代化编辑器**

[![原项目](https://img.shields.io/badge/原项目-neovim--neovim-blue?style=flat-square&logo=github)](https://github.com/neovim/neovim)
[![中文文档](https://img.shields.io/badge/中文文档-README.zh--CN.md-orange?style=flat-square)](README.zh-CN.md)
[![GitHub Stars](https://img.shields.io/github/stars/neovim/neovim?style=flat-square&label=原项目Stars)](https://github.com/neovim/neovim/stargazers)
[![微信联系](https://img.shields.io/badge/微信-uaycar-brightgreen?style=flat-square&logo=wechat)](#)

</div>

---

> 这是 [neovim/neovim](https://github.com/neovim/neovim) 的中文翻译版本。
> 完整源代码请访问原项目:https://github.com/neovim/neovim

**代部署 / 定制服务 / 技术咨询 请添加微信:uaycar**

---

## 📖 项目简介

Neovim 是一个对 [Vim](https://www.vim.org/) 进行激进重构的项目,目标是简化维护、鼓励社区贡献,并让多个开发者能够并行分工。它允许在不改动核心代码的前提下接入高级 UI,并把可扩展性发挥到极致。Neovim 与绝大多数 Vim 插件兼容(包括 Ruby 和 Python 插件),同时引入了 Lua 脚本、内置 LSP 等现代化能力,已成为当下最受欢迎的终端编辑器之一。

## ✨ 主要特性

- 现代化的 [GUI 前端](https://github.com/neovim/neovim/wiki/Related-projects#gui)支持
- [API 可从任意语言调用](https://github.com/neovim/neovim/wiki/Related-projects#api-clients):C/C++、C#、Go、Java/Kotlin、JavaScript/Node.js、Lua、Python、Rust 等
- 内嵌可脚本化的[终端模拟器](https://neovim.io/doc/user/terminal.html)
- 异步[任务控制](https://github.com/neovim/neovim/pull/2247)(job control)
- 多实例间[共享数据(Shada)](https://github.com/neovim/neovim/pull/2506)
- 支持 [XDG 基础目录规范](https://github.com/neovim/neovim/pull/3470)
- 兼容绝大多数 Vim 插件,包括 Ruby 和 Python 插件

完整特性列表见 `:help nvim-features`,最新版本的重要变更见 `:help news`。

## 📁 文件说明

| 文件 | 说明 |
|:-----|:-----|
| README.md | 本文件(中文简介) |
| README.zh-CN.md | 详细中文文档(完整汉化) |

## 🚀 快速开始

1. 从 [Releases](https://github.com/neovim/neovim/releases/) 页面下载 Windows / macOS / Linux 预编译包,直接解压运行。
2. 也可使用包管理器安装:Homebrew、Debian、Ubuntu、Fedora、Arch Linux、Void Linux、Gentoo 等均已收录。
3. 从源码构建(基于 CMake):安装依赖后执行:

```bash
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
```

4. 安装到自定义位置:

```bash
make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/full/path/
make install
```

5. 从 Vim 迁移:参考 `:help nvim-from-vim`,配置文件放在 `~/.config/nvim/init.lua`(或 `init.vim`)。
6. 上手后运行 `:Tutor` 进入交互教程,`:help` 查阅内置文档。

完整源代码与最新版本请访问原项目:https://github.com/neovim/neovim

## 📞 联系方式

**代部署 / 定制服务 / 技术咨询 请添加微信:uaycar**

---

本项目为 [neovim/neovim](https://github.com/neovim/neovim) 的中文翻译版本,所有代码版权归原项目作者所有,遵循其原始许可证(Apache 2.0)。

**如果觉得有用,请给原项目点个 Star!** ⭐
