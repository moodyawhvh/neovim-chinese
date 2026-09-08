> 🌐 本文档由 [neovim/neovim](https://github.com/neovim/neovim) 翻译,英文原版见原项目。

参与 Neovim 贡献
================

入门
------

如果你刚接触这个代码库,先读 [:help dev-quickstart](https://neovim.io/doc/user/dev_tools.html#dev-quickstart),
了解如何跑测试、如何上手改代码。

如果想帮忙但不知道从哪下手,这里有一些低风险/相对独立的任务:

- 试试 [complexity:low] 标签的 issue。
- 修复 [Coverity](#coverity) 发现的 bug。
- [合并 Vim 补丁](https://neovim.io/doc/user/dev_vimpatch.html)(需要对 Vim 相当熟悉)
  - 注意:向 "runtime 文件"(`runtime/` 下的所有内容)提交改进之前,先读完上面的链接。
    - *Vimscript* 文件(大部分)由 [Vim](https://github.com/vim/vim) 维护,不是 Nvim。
    - *Lua* 文件由 *Nvim* 维护。
    - Nvim 的[文件类型检测](https://github.com/neovim/neovim/blob/master/runtime/lua/vim.filetype.lua)行为与 Vim 一致,因此文件类型检测相关的修改应先提交给 [Vim](https://github.com/vim/vim)。

报告问题
--------

- [先查 FAQ][wiki-faq]。
- [搜索已有 issue][github-issues](包括已关闭的!)
- 把 Neovim 更新到最新版,看看问题是否仍然存在。
- 用 `nvim --clean`("出厂默认设置")尝试复现。
- 如果必须配合特定配置或插件才能复现,请基于 `contrib/minimal.lua` 的最小模板修改,然后用 `nvim --clean -u contrib/minimal.lua` 运行。
- 对你的配置做[二分排查](https://neovim.io/doc/user/starting.html#bisect):逐步禁用插件,缩小问题范围。
- 如果可以,请对 Neovim 源码做 [git bisect][git-bisect] 找出引入回归的提交,这_极其_有帮助。
- 报告崩溃时,[附上堆栈回溯](https://neovim.io/doc/user/dev_tools.html#dev-tools-backtrace)。
- 用 [ASAN/UBSAN](#sanitizers-asan-and-ubsan) 获取段错误和未定义行为的详细报错。
- 查看日志。`:edit $NVIM_LOG_FILE`
- 构建相关的问题请附上 `cmake --system-information` 的输出。

开发者指南
----------

- 新功能一般应该用 Lua 实现,而不是 C。PR [#37757](https://github.com/neovim/neovim/pull/37757)、[#37831](https://github.com/neovim/neovim/pull/37831) 是很好的范例。
- 读 [:help dev-quickstart](https://neovim.io/doc/user/dev_tools.html#dev-quickstart),了解如何跑测试、如何上手改代码。
- 参与 Nvim 核心开发,请读 [:help dev](https://neovim.io/doc/user/dev.html#dev) 和 [:help dev-doc][dev-doc-guide]。
- 开发 UI 请读 [:help dev-ui](https://neovim.io/doc/user/dev.html#dev-ui)。
- 开发 API 客户端请读 [:help dev-api-client](https://neovim.io/doc/user/dev.html#dev-api-client)。
- 安装 `ninja` 加快 Nvim 构建:
  ```bash
  sudo apt-get install ninja-build
  make distclean
  make  # 只要装了 ninja,构建系统会自动使用。
  ```
- 安装 `ccache` 或 `sccache` 加快增量重编译。Nvim 检测到其中之一会自动启用。要禁用缓存:
  ```bash
  cmake -B build -D CACHE_PRG=OFF
  ```

拉取请求(PR)
-------------

### 基本准则

- 不要申请认领某个 issue,直接发一个(基本完整的)PR,没准备好评审前先标为 Draft。
- PR 必须包含[测试覆盖][run-tests]。
- 避免在同一个 commit 里对无关文件做美化性修改。
- 使用[特性分支][git-feature-branch],不要直接用 master 分支。
- 采用 _rebase 工作流_。处理完评审意见后,force-push 是允许的。

### AI 辅助工作

允许使用 AI 辅助贡献,但须遵守以下要求:

- 在把 PR 从 Draft 转正之前,YOU 必须亲自审查输出。在你亲自检查 AI 生成的 PR 并确认下列事项之前,不要请求评审:
- 删掉文档、注释、PR 描述、commit message 等内容里的废话和灌水。所有内容(包括命名)都应简洁清晰,只保留有用信息。
- 删除并去重冗余的代码、测试、解释等。显式和清晰是好事,但啰嗦、过度解释和重复是坏事。

### 合并到 master

给维护者:当一个 PR 准备合并进 master 时,

- "单 commit PR"(只有一个有意义的提交)优先用 _Squash Merge_。
- "多 commit PR"(有多个有意义的提交)优先用 _Merge_。

### 阶段:Draft 与 Ready for review

PR 有两个阶段:Draft 和 Ready for review。

1. _不_想收反馈、还在继续改的时候,[创建 Draft PR][pr-draft]。
2. PR 可以评审了就[改为 Ready][pr-ready]。
    - 随时可以改回 Draft。

不要在标题里加 `[RFC]`、`[WIP]` 之类的标签来表示 PR 状态,那只是噪音。

### PR 描述

对 bugfix 而言,PR 标题应与 (1) "Problem" 描述和 (2) 测试用例名基本一致。示例 [PR #38048](https://github.com/neovim/neovim/pull/38048):

- 标题:`fix(lua): extra CR (\r) in nvim -l output`
- 问题:`nvim -l prints an extra \r to stdout: ...`
- 测试名:`it('outputs the EOF as LF (not CRLF) #36853' ...`

### Commit message

遵循 [conventional commits 规范][conventional_commits],这样评审更轻松、VCS/git 历史更有价值(可以试试 `make lintcommit`)。commit message 结构:

    type(scope): subject

    Problem:
    ...

    Solution:
    ...

- commit message **subject**(对 "fixup" 提交或预期会被 squash 的提交可以**忽略此节**):
    - 前缀用 [_type_](https://github.com/commitizen/conventional-commit-types/blob/master/index.json):
        - `build ci docs feat fix perf refactor revert test vim-patch`
    - 可附加 `(scope)`,如 `(lsp)`、`(treesitter)`、`(float)` 等
    - 用祈使语气:"Fix bug",而不是 "Fixed bug" 或 "Fixes bug"
    - 保持简短(72 字符以内)
- commit message **body**(正文):
    - 在正文里简洁描述 Problem/Solution。[把问题描述得_独立于解决方案_](https://lamport.azurewebsites.net/pubs/state-the-problem.pdf)往往能让你、评审者和未来的读者理解得更透彻。
      ```
      Problem:

      Solution:
      ```
- 破坏性 API 变更:在 type 后加 "!",并附 "BREAKING CHANGE" footer。示例:
  ```
  refactor(provider)!: drop support for Python 2

  BREAKING CHANGE: refactor to use Python 3 features since Python 2 is no longer supported.
  ```

### 自动化构建(CI)

每个 PR 都必须通过 [GitHub Actions] 上的自动构建。

- CI 构建启用了 [`-Werror`][gcc-warnings],编译器警告会直接导致构建失败。
- 任何测试失败都会导致构建失败。本地跑测试见 [test/README.md#running-tests][run-tests]。
- CI 会跑 [ASan] 等分析器。
    - 本地跑 valgrind:`VALGRIND=1 make test`
    - 本地跑 ASan/UBSan:`CC=clang make CMAKE_FLAGS="-DENABLE_ASAN_UBSAN=ON"`。
      注意 MSVC 需要 Release 或 RelWithDebInfo 构建类型才能正常工作。
- [lint](#lint) 构建会检查代码格式是否正确,并运行各类 linter。
- 想更快看到 PR 的 CI 结果,可以临时在 [test.yml](https://github.com/neovim/neovim/blob/ad8e0cfc1dfd937c2577dc032e524c799a772693/.github/workflows/test.yml#L26) 里设置 `TEST_FILE`。

### Coverity

Coverity 针对 master 构建运行。查看缺陷需要先[申请访问权限](https://scan.coverity.com/projects/neovim-neovim)(Coverity 没有"公开"视图),维护者看到邮件后很快会批准。

- commit message 用这种格式(`{id}` 是 CID(Coverity ID);[示例](https://github.com/neovim/neovim/pull/804)):
  ```
  fix(coverity/{id}): {description}
  ```
- 在 Neovim 提交历史里搜索示例:
  ```bash
  git log --oneline --no-merges --grep coverity
  ```

### Sanitizer(ASAN 与 UBSAN)

  在 debug 构建中,ASAN/UBSAN 可以在运行时检测内存错误和其他常见未定义行为。

- 启用 sanitizer 构建 Neovim:
  ```
  rm -rf build && CMAKE_EXTRA_FLAGS="-DCMAKE_C_COMPILER=clang -DENABLE_ASAN_UBSAN=1" make
  ```
- 运行 Neovim 时:
  ```
  ASAN_OPTIONS=log_path=/tmp/nvim_asan nvim args...
  ```
- 如果 Neovim 异常退出,检查 `/tmp/nvim_asan.{PID}`(或你设置的 `log_path`)下的日志文件获取错误信息。


编码
----

### Lint

本地运行 linter:

```bash
make lint  # 或 lintc, lintlua, lintquery, lintdoc
```

### 代码风格

- 格式化文件:
  ```bash
  make format  # 或 formatc, formatlua, formatquery
  ```
  会按全部相应配置格式化改动过的 C、Lua 和 treesitter query 文件。
- 风格规则(大部分)由 `src/uncrustify.cfg` 定义,它与[风格指南][style-guide]保持一致。想在 Nvim 里用 `gq` 调 `uncrustify`:
  ```vim
  if !empty(findfile('src/uncrustify.cfg', ';'))
    setlocal formatprg=uncrustify\ -q\ -l\ C\ -c\ src/uncrustify.cfg\ --no-backup
  endif
  ```

### 代码导航

- 设置 `blame.ignoreRevsFile`,让 git blame 忽略[噪音提交](https://github.com/neovim/neovim/commit/2d240024acbd68c2d3f82bc72cb12b1a4928c6bf):
  ```bash
  git config blame.ignoreRevsFile .git-blame-ignore-revs
  ```

- 推荐使用 **[clangd]**。可以直接用 [nvim-lspconfig/clangd] 里维护的配置。
- 也可以[在网页上](https://sourcegraph.com/github.com/neovim/neovim)浏览源码。

### 头文件包含

管理 C 文件的 include 用 [include-what-you-use]。

- [安装 include-what-you-use][include-what-you-use-install]
- 用 cmake preset `iwyu` 查看哪些 include 需要修:
  ```bash
  cmake --preset iwyu
  cmake --build build
  ```
- 还有自动修复 IWYU 建议的 make 目标:
  ```bash
  make iwyu
  ```

更多细节见 [#549][549]。

### Lua 运行时文件

Lua 的 [`runtime/lua/vim/_core/`](./runtime/lua/vim/_core/) 模块会被预编译成字节码,所以改动要生效必须:(1) 重新构建 Nvim,或 (2) 用 `--luamod-dev` 和 `$VIMRUNTIME` 启动 Nvim。例如往 `runtime/lua/vim/_core/editor.lua` 加个函数,然后:

```bash
VIMRUNTIME=./runtime ./build/bin/nvim --luamod-dev
```

文档
----

读 [:help dev-doc][dev-doc-guide] 了解文档的预期风格和约定。

### 生成 :help

很多 `:help` 文档由(C 或 Lua)docstring 自动生成。生成文档:

```bash
make doc
```

校验文档文件:

```bash
make lintdoc
```

如果需要修改或调试文档生成流程,主要涉及这些文件:
- `./src/gen/gen_vimdoc.lua`:主文档生成器,解析 C 和 Lua 文件并渲染 vimdoc。
- `./src/gen/luacats_parser.lua`:Lua 文件文档解析器。
- `./src/gen/cdoc_parser.lua`:C 文件文档解析器。
- `./src/gen/luacats_grammar.lua`:LuaCATS 的 Lpeg 文法。
- `./src/gen/cdoc_grammar.lua`:C 文档注释的 Lpeg 文法。
- `./src/gen/gen_eval_files.lua`:从元数据文件生成文档和 Lua 类型文件:
  ```
  runtime/lua/vim/*     =>  runtime/doc/lua.txt
  runtime/lua/vim/*     =>  runtime/doc/lua.txt
  runtime/lua/vim/lsp/  =>  runtime/doc/lsp.txt
  src/nvim/api/*        =>  runtime/doc/api.txt
  src/nvim/eval.lua     =>  runtime/doc/vimfn.txt
  src/nvim/options.lua  =>  runtime/doc/options.txt
  ```

- `./scripts/lintdoc.lua`:文档文件校验与 lint。

### Lua docstring

在 Lua docstring 里用 [LuaCATS] 注解标注参数类型、返回类型等,见 [:help dev-lua-doc][dev-lua-doc]。

运行 `make emmylua-check` 可用 [EmmyLua] 检查 runtime。构建会自动下载固定版本的检查器,配置在 `.emmyrc.json`。

第三方依赖
----------

想用依赖的其他 commit 构建 Nvim,改 `cmake.deps/deps.txt` 里对应的 URL 即可。例如换一个 luajit 版本,把 `LUAJIT_URL` 的值替换成想要的 commit hash:

```bash
LUAJIT_URL https://github.com/LuaJIT/LuaJIT/archive/<sha>.tar.gz
```

在 `cmake.deps/CMakeLists.txt` 里把 `DEPS_IGNORE_SHA` 设为 `TRUE` 可以跳过 cmake 的 hash 校验。

也可以把 URL 指向本地仓库路径。这对用 `git bisect` 二分排查依赖问题很方便。这种做法下每次构建之间可能需要 `make distclean`;此时无论 `DEPS_IGNORE_SHA` 为何都会跳过 hash 校验。

```bash
LUAJIT_URL /home/user/luajit
```

代码评审
--------

评审可以在 GitHub 上做,但在本地往往更顺手。用 [GitHub CLI][gh] 可以把 PR 内容检出到新分支,例如 [#1820][1820]:

```bash
gh pr checkout https://github.com/neovim/neovim/pull/1820
```

用 [`git log -p master..FETCH_HEAD`][git-history-filtering] 列出特性分支上不在 `master` 里的所有提交;`-p` 显示每个提交的 diff。想看改动所在函数的完整上下文,再加 `-W` 参数。

[549]: https://github.com/neovim/neovim/issues/549
[1820]: https://github.com/neovim/neovim/pull/1820
[ASan]: http://clang.llvm.org/docs/AddressSanitizer.html
[GitHub Actions]: https://github.com/neovim/neovim/actions
[Vim]: https://github.com/vim/vim
[clangd]: https://clangd.llvm.org
[Merge a Vim patch]: https://neovim.io/doc/user/dev_vimpatch.html
[complexity:low]: https://github.com/neovim/neovim/issues?q=is%3Aopen+is%3Aissue+label%3Acomplexity%3Alow
[conventional_commits]: https://www.conventionalcommits.org
[dev-doc-guide]: https://neovim.io/doc/user/dev.html#dev-doc
[dev-lua-doc]: https://neovim.io/doc/user/dev.html#dev-lua-doc
[LuaCATS]: https://luals.github.io/wiki/annotations/
[EmmyLua]: https://github.com/EmmyLuaLs/emmylua-analyzer-rust
[gcc-warnings]: https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
[gh]: https://cli.github.com/
[git-bisect]: http://git-scm.com/book/en/v2/Git-Tools-Debugging-with-Git
[git-feature-branch]: https://www.atlassian.com/git/tutorials/comparing-workflows
[git-history-filtering]: https://www.atlassian.com/git/tutorials/git-log/filtering-the-commit-history
[github-issues]: https://github.com/neovim/neovim/issues
[include-what-you-use-install]: https://github.com/include-what-you-use/include-what-you-use#how-to-install
[include-what-you-use]: https://github.com/include-what-you-use/include-what-you-use#using-with-cmake
[nvim-lspconfig/clangd]: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#clangd
[pr-draft]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request
[pr-ready]: https://docs.github.com/en/github/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/changing-the-stage-of-a-pull-request
[run-tests]: https://github.com/neovim/neovim/blob/master/runtime/doc/dev_test.txt
[style-guide]: https://neovim.io/doc/user/dev_style.html#dev-style
[wiki-faq]: https://neovim.io/doc/user/faq.html
