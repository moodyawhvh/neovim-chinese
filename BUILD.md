> 🌐 本文档由 [neovim/neovim](https://github.com/neovim/neovim) 翻译,英文原版见原项目。
>
> 📝 注:本文件超过 10000 字符,仅翻译核心章节(快速开始、构建、构建依赖、本地化等);Windows 各工具链、Nix/zig 交叉编译等细节请参阅英文原版 BUILD.md。

- **重要**:升级到新版本之前,**务必先查看[破坏性变更](https://neovim.io/doc/user/news.html#news-breaking)。**


## 快速开始

1. 在系统上安装[构建依赖](#构建依赖build-prerequisites)
2. `git clone https://github.com/neovim/neovim`
3. `cd neovim`
    - 想要**稳定版**,再执行 `git checkout stable`。
4. `make CMAKE_BUILD_TYPE=RelWithDebInfo`
    - 想装到自定义位置,设置 `CMAKE_INSTALL_PREFIX`。另见 [INSTALL.md](./INSTALL.md)。
    - BSD 上用 `gmake` 代替 `make`。
    - Windows 构建见英文原版 "Building on Windows" 一节。_推荐使用 MSVC (Visual Studio)。_
5. `sudo make install`
    - 默认安装位置是 `/usr/local`
    - Debian/Ubuntu 上可以不 `sudo make install`,改用 `cd build && cpack -G DEB && sudo dpkg -i nvim-linux-<arch>.deb`(`<arch>` 为 `x86_64` 或 `arm64`)构建 DEB 包再安装,便于干净卸载。注意:这是 Nvim 构建的"尽力而为"特性,非官方支持。

**注意事项**:
- 在仓库根目录运行 `make` 会自动下载并构建全部依赖,`nvim` 可执行文件在 `build/bin`。
- 第三方依赖(libuv、LuaJIT 等)自动下载到 `.deps/`。有问题看 [FAQ](https://neovim.io/doc/user/faq.html#faq-build)。
- 构建完成后无需安装即可运行:`VIMRUNTIME=runtime ./build/bin/nvim`。
- 打算开发 Neovim 的话,装 [Ninja](https://ninja-build.org/) 加快构建,会自动启用。
- 装 [ccache](https://ccache.dev/) 加快增量重编译,默认启用。禁用:`CCACHE_DISABLE=true make`。

## 运行测试

见 [test/README.md](https://github.com/neovim/neovim/blob/master/test/README.md)。

## 构建

先确认装好了[构建依赖](#构建依赖build-prerequisites),然后可以尝试下面介绍的其他构建目标。

_构建类型_决定编译器优化级别和调试信息:

- `Release`:完全优化,无调试信息。性能最好,打包维护者常用。
- `Debug`:完整调试信息,几乎不优化。开发时用它,让 GDB/LLDB 等调试器输出有意义的内容。未指定 `CMAKE_BUILD_TYPE` 时的默认值。
- `RelWithDebInfo`("Release With Debug Info"):大量优化 + 足够的调试信息,崩溃时仍能拿到回溯。

发布构建直接用:

```bash
make CMAKE_BUILD_TYPE=Release
```
(装了 `ninja` 就**不要**加 `-j`!构建会自动并行。)

构建产物在 `build/bin`。编译后验证构建类型:

```bash
./build/bin/nvim --version | grep ^Build
```

安装到指定位置:

```bash
make CMAKE_INSTALL_PREFIX=$HOME/local/nvim install
```

主构建系统 CMake 会在 `build/CMakeCache.txt` 缓存大量内容。要改 `CMAKE_BUILD_TYPE` 或 `CMAKE_INSTALL_PREFIX`,先 `rm -rf build`。Git 提交增删了文件(包括 `runtime`)后重新构建也需要这一步——拿不准就 `make distclean`(约等于 `rm -rf build .deps`)。

默认(`USE_BUNDLED=1`)会下载依赖并静态链接。想用调试器调试这些库,需要带调试信息编译它们:

```bash
make distclean
make deps
```

### PUC Lua

想用 "PUC Lua" 代替 LuaJIT 构建:
```bash
make CMAKE_EXTRA_FLAGS="-DPREFER_LUA=ON" DEPS_CMAKE_FLAGS="-DUSE_BUNDLED_LUAJIT=OFF -DUSE_BUNDLED_LUA=ON"
```

### 构建选项

查看本项目定义的全部 CMake 选项:
```bash
cmake -B build -LH
```

## Windows 构建(概要)

**Windows 上推荐用 MSVC (Visual Studio) 构建。** 要点:

1. 安装 [Visual Studio](https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Community)(2017+)并勾选 _Desktop development with C++_ 工作负载。
2. 打开 Neovim 项目文件夹,VS 会检测 CMake 文件并自动开始构建。
3. 选择 `nvim.exe (bin\nvim.exe)` 目标按 F5。
4. 命令行构建:在 "Developer PowerShell" 或 "Developer Command Prompt" 里:
   ```bash
   cmake -S cmake.deps -B .deps -G Ninja -D CMAKE_BUILD_TYPE=Release
   cmake --build .deps --config Release
   cmake -B build -G Ninja -D CMAKE_BUILD_TYPE=Release
   cmake --build build --config Release
   ```

CLion、Cygwin、MSYS2/MinGW、WSL 等其他工具链的完整步骤见英文原版 BUILD.md 的 "Building on Windows" 一节。WSL 构建若遇到链接错误或段错误,用干净 PATH 构建:`PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" make CMAKE_BUILD_TYPE=RelWithDebInfo`。

## 本地化

### 本地化构建

翻译默认关闭。用 CMake 选项 `ENABLE_TRANSLATIONS=ON` 启用,会在 `build/src/nvim/po` 生成 `.mo` 文件:

```bash
make CMAKE_EXTRA_FLAGS="-DENABLE_TRANSLATIONS=ON"
```

* 报 `msgfmt: command not found` 就装 [`gettext`](http://en.wikipedia.org/wiki/Gettext),多数系统包名就是 `gettext`。

### 本地化检查

检查 `$LANG` 的翻译:`make -C build check-po-$LANG`,例如:

```bash
cmake --build build --target check-po-de
cmake --build build --target check-po-pt_BR
```

- `check-po-$LANG` 会在 `./build/src/nvim/po/check-${LANG}.log` 生成详细报告(由 `nvim` 而非 `msgfmt` 生成)。

### 本地化更新

用最新字符串更新 `src/nvim/po/$LANG.po`:

```bash
cmake --build build --target update-po-$LANG
```

- **注意**:更新后运行 `src/nvim/po/cleanup.vim`。

## 自定义 Makefile

创建 `local.mk` 可在本地定制构建流程,它在主 `Makefile` 顶部被引用,且已列入 `.gitignore`,可跨分支使用。**`local.mk` 里的新目标会覆盖默认 make 目标。**

示例 `local.mk`(加一个强制重建的目标,但*不*覆盖默认目标):

```make
all:

rebuild:
	rm -rf build
	make
```

## 第三方依赖

精确的依赖/版本清单参考 [Debian 包](https://packages.debian.org/sid/source/neovim)(或 [Homebrew formula](https://github.com/Homebrew/homebrew-core/blob/master/Formula/n/neovim.rb))。

用 CMake 构建 bundled 依赖:

```bash
cmake -S cmake.deps -B .deps -G Ninja -D CMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build .deps
```

库和头文件默认放在 `.deps/usr`,然后构建 Neovim:

```bash
cmake -B build -G Ninja -D CMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build
```

### 不用 "bundled" 依赖构建

1. 手动安装依赖:libuv libluv libutf8proc luajit lua-lpeg tree-sitter 及各语言 parser、unibilium。
2. 运行 CMake:
   ```bash
   cmake -B build -G Ninja -D CMAKE_BUILD_TYPE=RelWithDebInfo
   cmake --build build
   ```
   系统包缺部分依赖时,可以只用部分 bundled 依赖:
   ```bash
   cmake -S cmake.deps -B .deps -G Ninja -D CMAKE_BUILD_TYPE=RelWithDebInfo -DUSE_BUNDLED=OFF -DUSE_BUNDLED_TS=ON
   cmake --build .deps
   cmake -B build -G Ninja -D CMAKE_BUILD_TYPE=RelWithDebInfo
   cmake --build build
   ```
3. 运行 `make`、`ninja` 或你让 CMake 生成的构建工具。强烈建议 `ninja`。
4. treesitter parsers 未 bundled 时,需存在于某个 `parser/` runtime 目录(如 `/usr/share/nvim/runtime/parser/`)。

### 离线构建

在库老旧/缺失且_无_网络的系统上,可以_带_ bundled 依赖构建:

1. 在有网的机器上准备 `.deps`:
    - 把 https://github.com/neovim/deps/tree/master/src 抓取到 `.deps/build/src/`(该仓库是 `.deps/build/src/` 的自动更新"清理版"快照);
    - 或 `make deps` 生成 `.deps/` 后按上游 build.yml 里的命令清理。
2. 把准备好的 `.deps` 拷到隔离机器。
3. 在隔离机器上开 `USE_EXISTING_SRC_DIR` 构建:
   ```bash
   make deps DEPS_CMAKE_FLAGS=-DUSE_EXISTING_SRC_DIR=ON
   make
   ```

### 不用 unibilium 构建

Unibilium 是唯一 LGPLv3 许可的依赖(没有纯 GPLv3 依赖)。它在运行时加载 terminfo 数据库,若内置的常见终端定义够用可以禁用:

```bash
make CMAKE_EXTRA_FLAGS="-DENABLE_UNIBILIUM=0" DEPS_CMAKE_FLAGS="-DUSE_BUNDLED_UNIBILIUM=0"
```

运行时确认未包含 unibilium:检查 `has('terminfo') == 1`。

### Linux 静态构建

1. 使用 musl C 库的发行版(推荐 Alpine;glibc 不支持静态链接)。
2. `make CMAKE_EXTRA_FLAGS="-DSTATIC_BUILD=1"`

非 Alpine 系统可用容器构建:

```bash
podman run \
  --rm \
  -it \
  -v "$PWD:/workdir" \
  -w /workdir \
  alpine:latest \
  sh -c 'apk add build-base cmake coreutils curl gettext-tiny-dev git linux-headers && make CMAKE_EXTRA_FLAGS="-DSTATIC_BUILD=1"'
```

产物 `build/bin/nvim` 将静态链接全部依赖。

## 构建依赖(Build Prerequisites)

通用要求(见 [#1469](https://github.com/neovim/neovim/issues/1469#issuecomment-63058312)):

- Clang 或 GCC 4.9+
- CMake 3.16+,且构建时带 TLS/SSL 支持
  - 可选:从 https://cmake.org/download/ 获取最新 CMake,确保 `cmake` 在 $PATH 里。

各平台安装命令速查:

| 平台 | 命令 |
| --- | --- |
| Ubuntu / Debian | `sudo apt-get install ninja-build gettext cmake curl build-essential git` |
| RHEL / Fedora | `sudo dnf -y install ninja-build cmake gcc make gettext curl glibc-gconv-extra git` |
| openSUSE | `sudo zypper install ninja cmake gcc-c++ gettext-tools curl git` |
| Arch Linux | `sudo pacman -S base-devel cmake ninja curl git` |
| Alpine Linux | `apk add build-base cmake coreutils curl gettext-tiny-dev git` |
| Void Linux | `xbps-install base-devel cmake curl git` |
| FreeBSD | `sudo pkg install cmake gmake sha wget gettext curl git` |
| OpenBSD | `doas pkg_add gmake cmake curl gettext-tools git ninja` |
| macOS (Homebrew) | `xcode-select --install` 后 `brew install ninja cmake gettext curl git` |
| macOS (MacPorts) | `xcode-select --install` 后 `sudo port install ninja cmake gettext git` |

NixOS / Nix、Haiku、旧版 macOS 部署目标(MACOSX_DEPLOYMENT_TARGET)、zig 构建及交叉编译(WASM 等)的详细说明见英文原版 BUILD.md。
