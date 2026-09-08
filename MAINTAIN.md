> 🌐 本文档由 [neovim/neovim](https://github.com/neovim/neovim) 翻译,英文原版见原项目。
>
> 📝 注:本文件超过 10000 字符,核心章节已全部翻译;依赖清单等长列表做了适度浓缩,完整细节见英文原版 MAINTAIN.md。

维护 Neovim 项目
================

关于维护 Neovim 项目的一些笔记。

通用准则
--------

* 按成本收益做决策
* 把决策记录下来
* 约束是好事
* 用自动化解决问题
* 永远不要破坏 API……但 UI 偶尔可以破坏

Issue 分类
----------

实践中我们没找到比"下一个"和"下下个"更精确的排期方式。所以通常只有一两个(最多)计划中的里程碑:

* 下一个 bugfix 发布版(1.0.x)
* 下一个 feature 发布版(1.x.0)

排期问题或许可以靠一套显式的优先级系统解决(类似 Vim 的 todo.txt)。目前 Neovim 的优先级由以下因素决定:

* 接近完成的 PR。
* Issue 标签。例如 `has:plan` 标签之所以能提升工单优先级,仅仅因为写下了计划:它比没有计划的工单_更接近完成_。
* 评论活跃度或新信息。

任何不在下一个里程碑里、也没有完成对应 PR 的东西——按构造就不值得太操心。版本发布后可以再回顾开放 issue,但那时你的下一个里程碑八成已经排满了…… :)

发布策略
--------

发布要"频繁",但不要"抢跑"。

(未发布的)`master` 分支是"抢先体验"渠道;不稳定就不该发版。如果下个发布不临近,高风险变更可以合入 `master`。

维护版本发布时,创建 `release-x.y` 分支。如果当前版本有重大 bug:

1. 在 `master` 上修复。
2. 把修复 cherry-pick 到 `release-x.y`。
3. 从 `release-x.y` 切一个发布:
    * 运行 `./scripts/release.sh`(需要 [git cliff](https://github.com/orhun/git-cliff))
    * [CI 任务](https://github.com/neovim/neovim/blob/3d45706478cd030c3ee05b4f336164bb96138095/.github/workflows/release.yml#L11-L13)会更新 release 资产并[force-push 到 "stable" 标签](https://github.com/neovim/neovim/blob/cdd87222c86c5b2274a13d36f23de0637462e317/.github/workflows/release.yml#L229)。

### 发布自动化

Neovim 自动化包含一个[回移机器人(backport bot)](https://github.com/korthout/backport-action)。给 PR 打上 `ci:backport release-x.y` 标签即可触发。见 `.github/workflows/backport.yml`。

特性的废弃与移除
----------------

Neovim 从 Vim 继承了大量特性和设计决策,并非全部符合本项目目标。有时需要移除既有特性,或重构会改变用户工作流的代码。这些情况下需要一套废弃政策,把变更正确地告知用户。

当一个(非实验性)特性计划被移除时,应按以下流程:

1. 在_下一个_版本做_软_废弃
    - 废弃特性仍然可用。
    - 即通过文档和注解(`@deprecated`)进行废弃。
    - 在 `deprecated.txt` 里加一条说明。
    - Lua 特性用 `vim.deprecate()`。指定的版本号 = 当前次版本号 + 2。例如当前版本是 `v0.10.0-dev-1957+gd676746c33`,就写 `0.12`。
    - Vimscript 特性用 `v:lua.vim.deprecate()`,版本号规则同上。
    - `vim.deprecate(…, 'x.y.z')` 中主版本 `x` 大于当前 Nvim 主版本时,一律按_软_废弃处理。
2. 在软废弃所在版本的_下一个_版本做_硬_废弃
    - 废弃特性仍可用,但必须发出警告。
    - C 实现的特性需要专门实现提示逻辑,告知用户该特性已废弃。
3. 在硬废弃所在版本的_下一个_版本移除
    - 通常是紧接的下一个版本;若想拉长废弃周期也可以更晚
    - 有条件的话保留特性 stub(如函数 API),访问时报错

示例:

                    Deprecation                            Removal
                         ┆                 ┆                 ┆
                         ┆      Soft       ┆      Hard       ┆
                         ┆   Deprecation   ┆   Deprecation   ┆
                         ┆     Period      ┆     Period      ┆
             ────────────────────────────────────────────────────────────
    Version:            0.10              0.11              0.12
             ────────────────────────────────────────────────────────────
             Old code         Old code          Old code
                                 +                 +
                              New code          New code         New code

可能需要社区意见或进一步讨论的特性移除,还应开一个跟踪 issue(并在 release notes 里链接)。

本政策可以有例外(实验性子系统,或维护者间达成广泛共识时)。例外的理由必须明确、公开地说明。

依赖
----

### 第三方依赖

(注意:与 `LICENSE.txt` 的 "external" 部分保持同步)。

"打包(bundled)"依赖通过修改 `cmake.deps/deps.txt` 里的版本号更新,部分可由 `scripts/bump_deps.lua` 自动升级。完整清单包括 LuaJIT、Lua、libuv、Luv(升级时需同步 bundled 的 meta 文件与文档)、gettext、libiconv、lua-compat、tree-sitter、treesitter parsers,以及(已废弃的)unibilium——unibilium 非必需,见 [BUILD.md](./BUILD.md#build-without-unibilium) 可在不启用它的情况下构建。

### 内嵌(vendored)依赖

"内嵌"进仓库源码树的依赖需手动更新源码,主要包括:`src/mpack/`(libmpack)、`src/mpack/lmpack.c`(libmpack-lua)、`src/xdiff/`、`src/cjson/`、`src/klib/`、`src/lpeg/`(与上游同步时打上 `src/lpeg/README.md` 里的补丁)、`runtime/lua/vim/inspect.lua`、`src/nvim/tui/terminfo_defs.h`(用 `scripts/update_terminfo.sh` 更新)、`runtime/lua/vim/lsp/_meta/protocol.lua`(用 `src/gen/gen_lsp.lua` 更新)、LSP/LPeg 相关的 `_meta` 文件与 `runtime/lua/vim/re.lua`,以及仅 PUC Lua 需要的 `src/bit.c` 和 `runtime/lua/coxpcall.lua`。欢迎把改进回馈上游!

运维依赖
--------------------------

* GitHub 机器人账号:https://github.com/marvim 、https://github.com/nvim-winget
* Org secrets/token:`CODECOV_TOKEN`、`BACKPORT_KEY`
* Org/repo 变量:`BACKPORT_APP`
* 域名(注册于 https://namecheap.com ):neovim.org、neovim.io、packspec.org、pkgjson.org
* 上述域名均通过 https://cloudflare.com 注册和管理


重构
----

### 冻结的遗留模块

在结构和风格上重构 Vim 是 Neovim 的重要目标。但有些模块目前由 Vim 维护,不应做大幅改动。在这些模块被"认领"之前,任何显著改动(包括调整代码的风格或结构)的成本都大于收益。这些模块是:

- `regexp.c`
- `indent_c.c`

自动化(CI)
---------------

### 备份

Issue 和 PR 的讨论内容备份在:https://github.com/neovim/neovim-backup

### 开发准则

* CI 和自动化任务主要由 GitHub Actions 驱动。
* 能用 Ubuntu 或 Windows runner 就别用 macOS,因为 macOS runner 对并发任务数有[更严格的限制](https://docs.github.com/en/actions/learn-github-actions/usage-limits-billing-and-administration#usage-limits)。
* Runner 版本:
    * 对 runner 版本无关紧要的特殊任务,优先用 `-latest` 标签,省得手动升版本(如 `labeler_pr.yml`)。
    * 测试任务 `test.yml` 建议显式指定最新版本,避免用 `-latest`:否则无法判断无关 PR 的失败是 PR 自身问题还是 GitHub 悄悄升级了 `-latest`;而且经验表明自动升级 CI 版本很容易翻车,需要人工介入。
    * 发布任务 `release.yml` 建议用最老的稳定(非弃用)版本:我们要产出在尽量多环境可用的镜像,所以倾向旧版本。

### 特殊标签

一些 GitHub 标签用于触发特定任务:

* `ci:backport release-x.y` - 回移到 `release-x.y` 分支
* `ci:s390x` - 启用 s390x CI
* `ci:skip-news` - 跳过 news.yml 工作流
* `ci:windows-asan` - 在 Windows 上启用 ASAN 测试
* `needs:response` - 超时未回应则自动关闭 PR

Vim 补丁
--------

`version.c` 跟踪了多个 Vim 版本,这样即使 `v:version` "落后",`has('patch-x.y.z')` 也能正常工作。每当合并完某个 Vim `v:version` 的全部补丁,按以下步骤升级 `v:version`:

1. 调整 `vim-patch.sh` 里的正则,移除已合并完的版本。例如移除 "8.1":
   ```diff
   diff --git a/scripts/vim-patch.sh b/scripts/vim-patch.sh
   index d64f6b6..1d3dcdf 100755
   --- a/scripts/vim-patch.sh
   +++ b/scripts/vim-patch.sh
   @@ -577,7 +577,7 @@ list_vimpatch_tokens() {
    # Left-pad the patch number of "vim-patch:xxx" for stable sort + dedupe.
    # Filter reverted Vim tokens.
    list_vimpatch_numbers() {
   -  local patch_pat='(8\.[12]|9\.[0-9])\.[0-9]{1,4}'
   +  local patch_pat='(8\.[2]|9\.[0-9])\.[0-9]{1,4}'
      diff "${NVIM_SOURCE_DIR}/scripts/vimpatch_token_reverts.txt" <(
        git -C "${NVIM_SOURCE_DIR}" log --format="%s%n%b" -E --grep="^[* ]*vim-patch:${patch_pat}" |
        grep -oE "^[* ]*vim-patch:${patch_pat}" |
   ```
2. 运行 `nvim -l scripts/vimpatch.lua` 重新生成 `version.c`,或等 `vim_patches.yml` CI 任务自动完成。


另见
----

* https://github.com/neovim/neovim/issues/862
* https://github.com/git/git/blob/master/Documentation/howto/maintain-git.adoc
