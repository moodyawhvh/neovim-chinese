> 🌐 本文档由 [neovim/neovim](https://github.com/neovim/neovim) 翻译,英文原版见原项目。

```
${NVIM_VERSION}
```

## 发布说明

- [更新日志](https://github.com/neovim/neovim/commit/${NVIM_COMMIT})(修复 + 新特性)
- [News](./runtime/doc/news.txt)(Nvim 内 `:help news`)

## 安装

### Windows

#### Zip

1. 下载 **nvim-win64.zip**(ARM 设备选 **nvim-win-arm64.zip**)
2. 解压
3. 在终端运行 `nvim.exe`

#### MSI

1. 下载 **nvim-win64.msi**(ARM 设备选 **nvim-win-arm64.msi**)
2. 运行 MSI 安装
3. 在终端运行 `nvim.exe`

注意:在 Windows "Server" 上可能需要[安装 `vcruntime*.dll`](https://neovim.io/doc/install/#windows)。

### macOS(x86_64)

1. 下载 **nvim-macos-x86_64.tar.gz**
2. 运行 `xattr -c ./nvim-macos-x86_64.tar.gz`(避免"未知开发者"警告)
3. 解压:`tar xzvf nvim-macos-x86_64.tar.gz`
4. 运行 `./nvim-macos-x86_64/bin/nvim`

### macOS(arm64)

1. 下载 **nvim-macos-arm64.tar.gz**
2. 运行 `xattr -c ./nvim-macos-arm64.tar.gz`(避免"未知开发者"警告)
3. 解压:`tar xzvf nvim-macos-arm64.tar.gz`
4. 运行 `./nvim-macos-arm64/bin/nvim`

### Linux(x86_64)

如果你的系统 glibc 版本不满足要求,可以试试(非官方支持的)[旧 glibc 构建版](https://github.com/neovim/neovim-releases)。

#### AppImage

1. 下载 **nvim-linux-x86_64.appimage**
2. 运行 `chmod u+x nvim-linux-x86_64.appimage && ./nvim-linux-x86_64.appimage`
   - 系统没有 FUSE 的话可以[解包 appimage](https://github.com/AppImage/AppImageKit/wiki/FUSE#type-2-appimage):
     ```bash
     ./nvim-linux-x86_64.appimage --appimage-extract
     ./squashfs-root/usr/bin/nvim
     ```

#### Tarball

1. 下载 **nvim-linux-x86_64.tar.gz**
2. 解压:`tar xzvf nvim-linux-x86_64.tar.gz`
3. 运行 `./nvim-linux-x86_64/bin/nvim`

### Linux(arm64)

#### AppImage

1. 下载 **nvim-linux-arm64.appimage**
2. 运行 `chmod u+x nvim-linux-arm64.appimage && ./nvim-linux-arm64.appimage`
   - 系统没有 FUSE 的话可以[解包 appimage](https://github.com/AppImage/AppImageKit/wiki/FUSE#type-2-appimage):
     ```bash
     ./nvim-linux-arm64.appimage --appimage-extract
     ./squashfs-root/usr/bin/nvim
     ```

#### Tarball

1. 下载 **nvim-linux-arm64.tar.gz**
2. 解压:`tar xzvf nvim-linux-arm64.tar.gz`
3. 运行 `./nvim-linux-arm64/bin/nvim`

### 其他

- 通过[软件包管理器](https://github.com/neovim/neovim/blob/master/INSTALL.md#install-from-package)安装
