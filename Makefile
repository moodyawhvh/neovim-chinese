# ============================================================
# Neovim 顶层 Makefile(汉化注释版)
> 🌐 本文件由 [neovim/neovim](https://github.com/neovim/neovim) 翻译注释,英文原版见原项目。
#
# 说明:仅新增/翻译注释,构建逻辑与上游保持一致。
# 常用目标:
#   make            构建 nvim(build/bin/nvim)
#   make install    安装(可用 CMAKE_INSTALL_PREFIX 指定位置)
#   make test       运行全部测试(functionaltest + unittest)
#   make distclean  彻底清理 build/.deps 等产物
# ============================================================

# 检测操作系统:Windows(含 MSYS/Cygwin 之外的 native 环境)与类 Unix 区分对待
ifeq ($(OS),Windows_NT)
  # PATH 中带分号说明是 native Windows(cmd/PowerShell),否则视为类 Unix 环境
  ifeq '$(findstring ;,$(PATH))' ';'
    UNIX_LIKE := FALSE
  else
    UNIX_LIKE := TRUE
  endif
else
  UNIX_LIKE := TRUE
endif

ifeq ($(UNIX_LIKE),FALSE)
  # native Windows:用 PowerShell 执行 recipe
  SHELL := powershell.exe
  .SHELLFLAGS := -NoProfile -NoLogo
  MKDIR := @$$null = new-item -itemtype directory -force
  TOUCH := @$$null = new-item -force
  RM := remove-item -force
  CMAKE := cmake
  CMAKE_GENERATOR := Ninja
  define rmdir
    if (Test-Path $1) { remove-item -recurse $1 }
  endef
else
  # 类 Unix:标准工具链;cmake 可能叫 cmake3(部分发行版)
  MKDIR := mkdir -p
  TOUCH := touch
  RM := rm -rf
  CMAKE := $(shell (command -v cmake3 || command -v cmake || echo cmake))
  # 装了 ninja 就默认用 Ninja 生成器,否则退回 Unix Makefiles
  CMAKE_GENERATOR ?= "$(shell (command -v ninja > /dev/null 2>&1 && echo "Ninja") || echo "Unix Makefiles")"
  define rmdir
    rm -rf $1
  endef
endif

# 当前 Makefile 所在的绝对路径(用于任意目录调用)
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR  := $(dir $(MAKEFILE_PATH))

# 布尔过滤辅助函数:从字符串里剔除所有表示"假"/"真"的词
filter-false = $(strip $(filter-out 0 off OFF false FALSE,$1))
filter-true = $(strip $(filter-out 1 on ON true TRUE,$1))

# 支持本地定制:contrib/local.mk.example 有说明;local.mk 已被 gitignore
-include local.mk

all: nvim

# 把构建类型透传给 CMake(如 make CMAKE_BUILD_TYPE=Release)
CMAKE_FLAGS := -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE)
# 追加的额外 CMake 选项
CMAKE_EXTRA_FLAGS ?=
NVIM_PRG := $(MAKEFILE_DIR)/build/bin/nvim

# CMAKE_INSTALL_PREFIX(安装前缀)
#   - 可以直接传参,也可以藏在 CMAKE_EXTRA_FLAGS 里。
#   - `checkprefix` 目标会校验它与 CMake 缓存值是否一致。#9615
ifneq (,$(CMAKE_INSTALL_PREFIX)$(CMAKE_EXTRA_FLAGS))
# 若前缀是通过 CMAKE_EXTRA_FLAGS 传入的,从里面把它抠出来
CMAKE_INSTALL_PREFIX := $(shell echo $(CMAKE_EXTRA_FLAGS) | 2>/dev/null \
    grep -o 'CMAKE_INSTALL_PREFIX=[^ ]\+' | cut -d '=' -f2)
endif
ifneq (,$(CMAKE_INSTALL_PREFIX))
# 统一回写到 CMAKE_EXTRA_FLAGS,保证只配置一次
override CMAKE_EXTRA_FLAGS += -DCMAKE_INSTALL_PREFIX=$(CMAKE_INSTALL_PREFIX)

# 校验:如果缓存值与本次传入的安装前缀不一致,清掉 .ran-cmake 强制重跑 CMake
checkprefix:
	@if [ -f build/.ran-cmake ]; then \
	  cached_prefix=$(shell $(CMAKE) -L -N build | 2>/dev/null grep 'CMAKE_INSTALL_PREFIX' | cut -d '=' -f2); \
	  if ! [ "$(CMAKE_INSTALL_PREFIX)" = "$$cached_prefix" ]; then \
	    printf "Re-running CMake: CMAKE_INSTALL_PREFIX '$(CMAKE_INSTALL_PREFIX)' does not match cached value '%s'.\n" "$$cached_prefix"; \
	    $(RM) build/.ran-cmake; \
	  fi \
	fi
else
checkprefix: ;
endif

# 依赖构建目录,不允许含空白字符
DEPS_BUILD_DIR ?= ".deps"
ifneq (1,$(words [$(DEPS_BUILD_DIR)]))
  $(error DEPS_BUILD_DIR must not contain whitespace)
endif

DEPS_CMAKE_FLAGS ?=
USE_BUNDLED ?=

# 旧变量已移除,显式报错提示新写法
ifdef BUNDLED_CMAKE_FLAG
  $(error BUNDLED_CMAKE_FLAG was removed. Use DEPS_CMAKE_FLAGS instead)
endif

ifdef BUNDLED_LUA_CMAKE_FLAG
  $(error BUNDLED_LUA_CMAKE_FLAG was removed. Use DEPS_CMAKE_FLAGS instead)
endif

# 如果设置了 USE_BUNDLED,把它前置拼进 DEPS_CMAKE_FLAGS
ifneq (,$(USE_BUNDLED))
  DEPS_CMAKE_FLAGS := -DUSE_BUNDLED=$(USE_BUNDLED) $(DEPS_CMAKE_FLAGS)
endif

# 目标包含 functionaltest-lua 时,强制启用 bundled Lua 并清掉旧构建标记
ifneq (,$(findstring functionaltest-lua,$(MAKECMDGOALS)))
  DEPS_CMAKE_FLAGS := -DUSE_BUNDLED_LUA=ON $(DEPS_CMAKE_FLAGS)
  $(shell [ -x $(DEPS_BUILD_DIR)/usr/bin/lua ] || $(RM) build/.ran-*)
endif

# 需要严格单任务串行执行时使用(会告警,但必须保留 SCRIPTS 参数)
SINGLE_MAKE = export MAKEFLAGS= ; $(MAKE)

# 主目标:先跑 CMake 配置 + 依赖,再编译
nvim: build/.ran-cmake deps
	$(CMAKE) --build build

# 只构建 libnvim 库目标
libnvim: build/.ran-cmake deps
	$(CMAKE) --build build --target libnvim

# 触碰 CMakeLists.txt 强制重新配置
cmake:
	$(TOUCH) CMakeLists.txt
	$(MAKE) build/.ran-cmake

# .ran-cmake 标记文件:CMake 配置完成后落一个戳,避免重复配置
build/.ran-cmake: | deps
	$(CMAKE) -B build -G $(CMAKE_GENERATOR) $(CMAKE_FLAGS) $(CMAKE_EXTRA_FLAGS) $(MAKEFILE_DIR)
	$(TOUCH) $@

# USE_BUNDLED 为假值时跳过依赖构建;否则配置并构建 .deps
ifneq ($(call filter-true,$(USE_BUNDLED)),)
deps: ;
else
deps: | build/.ran-deps-cmake
	$(CMAKE) --build $(DEPS_BUILD_DIR)

$(DEPS_BUILD_DIR):
	$(MKDIR) $@
# 依赖目录的 CMake 配置戳(双冒号规则,可被多处定义)
build/.ran-deps-cmake:: $(DEPS_BUILD_DIR)
	$(CMAKE) -S $(MAKEFILE_DIR)/cmake.deps -B $(DEPS_BUILD_DIR) -G $(CMAKE_GENERATOR) $(DEPS_CMAKE_FLAGS)
endif

build/.ran-deps-cmake::
	$(MKDIR) build
	$(TOUCH) "$@"

# TODO: cmake 3.2+ 的 add_custom_target() 有 USES_TERMINAL 标志可用
# 老式(Vim 风格)测试:test/old/testdir 下的 .vim 测试集
oldtest: | nvim
	$(SINGLE_MAKE) -C test/old/testdir clean
ifeq ($(strip $(TEST_FILE)),)
	$(SINGLE_MAKE) -C test/old/testdir NVIM_PRG=$(NVIM_PRG) $(MAKEOVERRIDES)
else
	@# 支持 TEST_FILE=test_foo{,.res,.vim} 三种写法
	$(SINGLE_MAKE) -C test/old/testdir NVIM_PRG=$(NVIM_PRG) SCRIPTS= $(MAKEOVERRIDES) $(patsubst %.vim,%,$(patsubst %.res,%,$(TEST_FILE)))
endif

# 直接用相对 .vim 文件名构建单个 oldtest 目标
.PHONY: phony_force
test/old/testdir/%.vim: phony_force nvim
	$(SINGLE_MAKE) -C test/old/testdir NVIM_PRG=$(NVIM_PRG) SCRIPTS= $(MAKEOVERRIDES) $(patsubst test/old/testdir/%.vim,%,$@)

# Lua 解释器下的功能测试
functionaltest-lua: | nvim
	$(CMAKE) --build build --target functionaltest

# 以下目标都委托给 CMake 对应 target:格式化 / lint / 测试 / 文档 / 基准
FORMAT=formatc formatlua formatquery format
LINT=lintlua lintsh lintc clang-analyzer lintcommit lintdoc lintdocurls lint emmylua-check lintquery linterrcodes
TEST=functionaltest unittest
generated-sources benchmark $(FORMAT) $(LINT) $(TEST) doc: | build/.ran-cmake
	$(CMAKE) --build build --target $@

test: $(TEST)

# iwyu 修复脚本可从下面地址下载:
# https://github.com/include-what-you-use/include-what-you-use/blob/master/fix_includes.py
# 在 $PATH 里放一个调用该 python 脚本的 iwyu-fix-includes shell 包装即可。
iwyu: build/.ran-cmake
	$(CMAKE) --preset iwyu
	$(CMAKE) --build build > build/iwyu.log
	iwyu-fix-includes --only_re="src/nvim" --ignore_re="(src/nvim/eval/encode.c\
	|src/nvim/auto/\
	|src/nvim/os/lang.c\
	|src/nvim/map.c\
	)" --nosafe_headers < build/iwyu.log
	$(CMAKE) -B build -U ENABLE_IWYU
	$(CMAKE) --build build

# 清理构建产物(保留 .deps)
clean:
ifneq ($(wildcard build),)
	$(CMAKE) --build build --target clean
endif
	$(MAKE) -C test/old/testdir clean

# 彻底清理:依赖目录、build、zig 缓存全部移除
distclean:
	$(call rmdir, $(DEPS_BUILD_DIR))
	$(call rmdir, build)
	$(call rmdir, .zig-cache)
	$(call rmdir, zig-out)
	$(MAKE) clean

# 安装(先校验安装前缀一致性)
install: checkprefix nvim
	$(CMAKE) --install build

# 生成 AppImage
appimage:
	bash scripts/genappimage.sh

# 构建带内嵌更新信息的 AppImage:
#   appimage-nightly:nightly 构建用
#   appimage-latest:正式发布用
appimage-%:
	bash scripts/genappimage.sh $*

.PHONY: test clean distclean nvim libnvim cmake deps install appimage checkprefix benchmark $(FORMAT) $(LINT) $(TEST)
