# neovim 中文文档

[![原项目](https://img.shields.io/badge/原项目-neovim--neovim-blue?style=flat-square&logo=github)](https://github.com/neovim/neovim)
[![中文文档](https://img.shields.io/badge/中文文档-README.zh--CN.md-orange?style=flat-square)](README.zh-CN.md)
[![微信联系](https://img.shields.io/badge/微信-uaycar-brightgreen?style=flat-square&logo=wechat)](#)

> 本文档是 [neovim/neovim](https://github.com/neovim/neovim) 官方 README 的中文翻译。所有代码与英文原版文档版权归原项目作者所有。**代部署 / 定制服务 / 技术咨询 请添加微信:uaycar**

---

## 简介

Neovim 是一个致力于对 [Vim](https://www.vim.org/) 进行激进重构的项目,其目标包括:

- 简化维护工作,鼓励[社区贡献](https://github.com/neovim/neovim/blob/master/CONTRIBUTING.md)
- 将开发工作分配给多位开发者并行推进
- 无需修改核心代码即可接入[高级 UI](https://github.com/neovim/neovim/wiki/Related-projects#gui)
- 最大化[可扩展性](https://neovim.io/doc/user/api-ui-events.html#api-ui-events)

更多信息请参阅 [Introduction](https://github.com/neovim/neovim/wiki/Introduction) Wiki 页面与 [Roadmap](https://neovim.io/roadmap/)。

## 主要特性

- 现代化的 [GUI 前端](https://github.com/neovim/neovim/wiki/Related-projects#gui)
- [API 可从任意语言调用](https://github.com/neovim/neovim/wiki/Related-projects#api-clients),包括 C/C++、C#、Clojure、D、Elixir、Go、Haskell、Java/Kotlin、JavaScript/Node.js、Julia、Lisp、Lua、Perl、Python、Racket、Ruby、Rust
- 内嵌可脚本化的[终端模拟器](https://neovim.io/doc/user/terminal.html)
- 异步[任务控制](https://github.com/neovim/neovim/pull/2247)
- 多个编辑器实例间[共享数据(Shada)](https://github.com/neovim/neovim/pull/2506)
- 支持 [XDG 基础目录规范](https://github.com/neovim/neovim/pull/3470)
- 兼容绝大多数 Vim 插件,包括 Ruby 和 Python 插件

完整特性列表参见 `:help nvim-features`,最新版本的重要变更参见 `:help news`。

## 安装

### 从预编译包安装

Windows、macOS 和 Linux 的预编译包可在 [Releases](https://github.com/neovim/neovim/releases/) 页面下载。

各发行版托管的包已收录于 [Homebrew](https://formulae.brew.sh/formula/neovim)、[Debian](https://packages.debian.org/testing/neovim)、[Ubuntu](https://packages.ubuntu.com/search?keywords=neovim)、[Fedora](https://packages.fedoraproject.org/pkgs/neovim/neovim/)、[Arch Linux](https://www.archlinux.org/packages/?q=neovim)、[Void Linux](https://voidlinux.org/packages/?arch=x86_64&q=neovim)、[Gentoo](https://packages.gentoo.org/packages/app-editors/neovim) 等。Windows 用户也可使用 `winget install Neovim.Neovim` 或 `scoop install neovim` 快速安装。

例如:

```bash
# macOS (Homebrew)
brew install neovim

# Arch Linux
pacman -S neovim

# Windows (Scoop)
scoop install neovim
```

### 从源码构建

详见 [BUILD.md](https://github.com/neovim/neovim/blob/master/BUILD.md) 与[支持的平台列表](https://neovim.io/doc/user/support.html#supported-platforms)。

构建基于 CMake,同时提供了便捷的 Makefile。安装依赖后执行:

```bash
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
```

安装到非默认位置:

```bash
make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/full/path/
make install
```

查看构建信息的 CMake 提示:

- `cmake --build build --target help` 列出全部构建目标
- `build/CMakeCache.txt`(或 `cmake -LAH build/`)包含所有 CMake 变量的最终取值
- `build/compile_commands.json` 展示每个编译单元的完整编译命令

## 使用

- 启动:终端运行 `nvim` 即可进入编辑器,首次使用建议先完成 `:Tutor` 交互教程
- 从 Vim 迁移:参见 [`:help nvim-from-vim`](https://neovim.io/doc/user/nvim.html#nvim-from-vim);配置文件位于 `~/.config/nvim/`(Windows 为 `~/AppData/Local/nvim/`),入口为 `init.lua` 或 `init.vim`
- 内置 LSP:通过 `vim.lsp.start()` 或 `:lua` 接入语言服务器,获得补全、跳转与诊断能力
- 插件生态:绝大多数 Vim 插件可直接使用,Lua 插件推荐浏览 [awesome-neovim](https://github.com/rockerBOO/awesome-neovim)
- 完整文档:https://neovim.io/doc/

## 项目结构

    ├─ cmake/           CMake 工具
    ├─ cmake.config/    CMake 定义
    ├─ cmake.deps/      拉取并构建依赖的子项目(可选)
    ├─ runtime/         插件与文档
    ├─ src/nvim/        应用源代码(见 src/nvim/README.md)
    │  ├─ api/          API 子系统
    │  ├─ eval/         Vimscript 子系统
    │  ├─ event/        事件循环子系统
    │  ├─ generators/   代码生成(预编译阶段)
    │  ├─ lib/          通用数据结构
    │  ├─ lua/          Lua 子系统
    │  ├─ msgpack_rpc/  RPC 子系统
    │  ├─ os/           底层平台代码
    │  └─ tui/          内置终端 UI
    └─ test/            测试(见 test/README.md)

## 许可证

自 [b17d96](https://github.com/neovim/neovim/commit/b17d9691a24099c9210289f16afb1a498a89d803) 起,Neovim 的贡献采用 Apache 2.0 许可证(从 Vim 复制的贡献除外,以 `vim-patch` 标记标识)。详见 [LICENSE.txt](https://github.com/neovim/neovim/blob/master/LICENSE.txt)。

---

> 本仓库是 [neovim/neovim](https://github.com/neovim/neovim) 的中文翻译版本,不包含任何源代码修改,完整源代码请访问原项目。**代部署 / 定制服务 / 技术咨询 请添加微信:uaycar**

**如果本文档对你有帮助,请给原项目 [neovim/neovim](https://github.com/neovim/neovim) 点个 Star!** ⭐
