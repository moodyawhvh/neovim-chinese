> 🌐 本文档由 [neovim/neovim](https://github.com/neovim/neovim) 翻译,英文原版见原项目。
>
> 📝 注:本文件超过 10000 字符,仅翻译核心章节;各发行版的冷门安装方式细节请参阅英文原版 INSTALL.md。

你可以通过[下载安装包](#从下载安装)、[软件包管理器](#通过软件包安装)或[源码编译](#从源码安装)这三种方式,在几秒钟内装好 Neovim。

---

- 启动 Neovim 请运行 `nvim`(不是 `neovim`)。
    - [发现插件](https://github.com/neovim/neovim/wiki/Related-projects#plugins)。
- 升级到新版本之前,**务必先查看 [Breaking Changes(破坏性变更)](https://neovim.io/doc/user/news.html#news-breaking)。**
- 配置文件(vimrc)相关内容见[常见问题](https://neovim.io/doc/user/faq.html#faq-general)。

---

从下载安装
==========

安装包可在 [Releases](https://github.com/neovim/neovim/releases) 页面下载。

* 最新[稳定版](https://github.com/neovim/neovim/releases/latest)
    * [macOS x86_64](https://github.com/neovim/neovim/releases/latest/download/nvim-macos-x86_64.tar.gz)
    * [macOS arm64](https://github.com/neovim/neovim/releases/latest/download/nvim-macos-arm64.tar.gz)
    * [Linux x86_64](https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz)
    * [Linux arm64](https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz)
    * [Windows x86_64](https://github.com/neovim/neovim/releases/latest/download/nvim-win64.msi)
    * [Windows arm64](https://github.com/neovim/neovim/releases/latest/download/nvim-win-arm64.msi)
* 最新[开发预览版(nightly)](https://github.com/neovim/neovim/releases/nightly)


通过软件包安装
============

各平台的软件包如下所示。(也可以选择[从源码构建 Neovim](#从源码安装)。)

## Windows

需要 Windows 8 及以上版本,不支持 Windows 7 或更旧的系统。

### [Winget](https://docs.microsoft.com/en-us/windows/package-manager/winget/)

- **稳定版:** `winget install Neovim.Neovim`
- **Nightly:** [winget 暂不支持](https://github.com/neovim/neovim/issues/38585)

### [Chocolatey](https://chocolatey.org)

- **稳定版:** `choco install neovim`(加 `-y` 可自动跳过确认提示)
- **Nightly:** `choco install neovim --pre`

### [Scoop](https://scoop.sh/)

```bash
scoop bucket add main
scoop install neovim
```

Scoop 的 extras bucket 里还有多个 Neovim GUI 可选:[scoop.sh/#/apps?q=neovim](https://scoop.sh/#/apps?q=neovim)

### MSI

> [!TIP]
> 如果提示缺少 `VCRUNTIME170.dll`,请安装 [Visual Studio C++ 运行库](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)(按你的系统选择 x86_64 或 x86)。
> 装了 scoop 的话可以直接:`scoop install vcredist`。

可以用下面的 PowerShell 脚本从 [Releases 页面](https://github.com/neovim/neovim/releases)安装 MSI:

- x86_64:
  ```pwsh
  iwr -Uri "https://github.com/neovim/neovim/releases/download/nightly/nvim-win64.msi" -OutFile nvim-win64.msi
  msiexec /i nvim-win64.msi /passive
  rm nvim-win64.msi
  ```
- arm64:
  ```pwsh
  iwr -Uri "https://github.com/neovim/neovim/releases/download/nightly/nvim-win-arm64.msi" -OutFile nvim-win-arm64.msi
  msiexec /i nvim-win-arm64.msi /passive
  rm nvim-win-arm64.msi
  ```

### Zip

1. 从 [Releases 页面](https://github.com/neovim/neovim/releases)选择一个压缩包(**nvim-winXX.zip**)。
2. 解压到任意位置即可,**无需**管理员权限。
    - `$VIMRUNTIME` 会自动指向该解压目录。
3. 在终端里运行 `nvim.exe`。
4. (可选)把 `bin` 目录(例如 `C:/Program Files/nvim/bin`)加入 PATH,
   这样就能在任意目录直接运行 `nvim`。

### 可选步骤

- Python 插件需要 `pynvim` 模块。推荐用 uv(https://docs.astral.sh/uv/ )安装;`--upgrade` 参数可确保装到最新版:
    ```bash
    uv tool install --upgrade pynvim
    ```
    - 详见 `:checkhealth` 与 `:help provider-python`。
- **init.vim("vimrc"):** 如果你已经装了 Vim,可以把 `%userprofile%/_vimrc` 复制为 `%userprofile%/AppData/Local/nvim/init.vim`,让 Neovim 直接复用你的 Vim 配置。


## macOS / OS X

### 预编译压缩包

[Releases](https://github.com/neovim/neovim/releases) 页面提供 macOS 10.15+ 的预编译二进制。

x86_64:
```bash
curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-x86_64.tar.gz
tar xzf nvim-macos-x86_64.tar.gz
./nvim-macos-x86_64/bin/nvim
```
arm64:
```bash
curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz
tar xzf nvim-macos-arm64.tar.gz
./nvim-macos-arm64/bin/nvim
```
### macOS 或 Linux 上的 [Homebrew](https://brew.sh)

```bash
brew install neovim
```

### [MacPorts](https://www.macports.org/)

```bash
sudo port selfupdate
sudo port install neovim
```

## Linux

### 预编译压缩包

[Releases](https://github.com/neovim/neovim/releases) 页面提供 Linux 系统的预编译二进制。

```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
```

然后把下面这行加进 shell 配置文件(`~/.bashrc`、`~/.zshrc` 等):
```bash
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
```

### AppImage("通用" Linux 包)

[Releases](https://github.com/neovim/neovim/releases) 页面提供了一个能在多数 Linux 系统上直接运行的 [AppImage](https://appimage.org)。无需安装,下载 `nvim-linux-x86_64.appimage` 直接运行即可。(如果你的发行版超过 4 年没更新,可能跑不起来。)以下步骤假定 `x86_64` 架构,ARM Linux 请换成 `arm64`。

```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage
./nvim-linux-x86_64.appimage
```

想让 nvim 全局可用:
```bash
mkdir -p /opt/nvim
mv nvim-linux-x86_64.appimage /opt/nvim/nvim
```

再往 shell 配置文件(`~/.bashrc`、`~/.zshrc` 等)加一行:
```bash
export PATH="$PATH:/opt/nvim/"
```

如果 `./nvim-linux-x86_64.appimage` 运行失败,试试:
```bash
./nvim-linux-x86_64.appimage --appimage-extract
./squashfs-root/AppRun --version

# 可选:让 nvim 全局可用。
sudo mv squashfs-root /
sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
nvim
```

### 常见发行版速查

| 发行版 | 安装命令 |
| --- | --- |
| Arch Linux | `sudo pacman -S neovim`(Git 版与 Nightly 见 AUR 的 [`neovim-git`](https://aur.archlinux.org/packages/neovim-git) / [`neovim-nightly-bin`](https://aur.archlinux.org/packages/neovim-nightly-bin);Python 模块 `sudo pacman -S python-pynvim`) |
| CentOS 8 / RHEL 8 | 先装 [EPEL](https://fedoraproject.org/wiki/EPEL),再 `yum install -y neovim python3-neovim` |
| Clear Linux OS | `sudo swupd bundle-add neovim`;Python 支持装 [python-basic bundle](https://github.com/clearlinux/clr-bundles/blob/master/bundles/python-basic) |
| Debian | `sudo apt-get install neovim`;Debian unstable 上可 `sudo apt-get install python3-neovim` |
| Fedora | Fedora 25 起 `sudo dnf install -y neovim python3-neovim`;nightly 可用 [Copr](https://copr.fedoraproject.org/coprs/agriffis/neovim-nightly/):`dnf copr enable agriffis/neovim-nightly` |
| Flatpak | `flatpak install flathub io.neovim.nvim` 后 `flatpak run io.neovim.nvim`;注意 Flatpak 版的 `init.vim` 位于 `~/.var/app/io.neovim.nvim/config/nvim` 而非 `~/.config/nvim` |
| Gentoo Linux | `emerge -a app-editors/neovim` |
| GNU Guix | `guix install neovim` |
| Nix / NixOS | `nix-env -iA nixpkgs.neovim`;flakes 用户:`nix profile install nixpkgs#neovim` |
| OpenSUSE | `sudo zypper in neovim`;Python 模块:`sudo zypper in python-neovim python3-neovim` |
| Snap | 稳定版 `sudo snap install nvim --classic`;nightly `sudo snap install --edge nvim --classic` |
| Ubuntu | `sudo apt install neovim`;Python 支持 `sudo apt install python3-neovim`;另有 [stable](https://launchpad.net/~neovim-ppa/+archive/ubuntu/stable) / [unstable](https://launchpad.net/~neovim-ppa/+archive/ubuntu/unstable) PPA(注意:PPA 由社区维护,非 Neovim 官方团队,问题请反馈 https://launchpad.net/~neovim-ppa ) |
| Void Linux | `sudo xbps-install -S neovim` |
| Alpine Linux | `sudo apk add neovim` |
| FreeBSD | `pkg install neovim`,或经 ports:`cd /usr/ports/editors/neovim/ && make install clean` |
| OpenBSD | `pkg_add neovim`,或经 ports:`cd /usr/ports/editors/neovim/ && make install` |
| Android | [Termux](https://github.com/termux/termux-app) 提供 Neovim 包 |

其他冷门平台(Mageia、makedeb/MPR、PLD、Slackware、Source Mage、Solus、Exherbo、GoboLinux 等)的安装方式请直接查看英文原版 INSTALL.md 对应小节。

从源码安装
==========

如果你的平台没有现成的软件包,可以从源码构建 Neovim。详见 [BUILD.md](./BUILD.md)。只要装好了[构建依赖](./BUILD.md#build-prerequisites),编译很简单:
```bash
make CMAKE_BUILD_TYPE=Release
sudo make install
```

类 Unix 系统上默认装到 `/usr/local`,Windows 上则是 `C:/Program Files`。不过这种装法卸载起来比较麻烦,下面的示例通过把安装隔离到 `$HOME/neovim` 来规避该问题:
```bash
rm -r build/  # 清除 CMake 缓存
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim"
make install
export PATH="$HOME/neovim/bin:$PATH"
```

## 卸载

`make install` 之后可以用 CMake 目标来_卸载_:

```bash
sudo cmake --build build/ --target uninstall
```

或者直接删掉 `CMAKE_INSTALL_PREFIX` 下的产物:

```bash
sudo rm /usr/local/bin/nvim
sudo rm -r /usr/local/share/nvim/
```
