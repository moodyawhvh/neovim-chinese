# ============================================================
# Neovim 主 CMakeLists.txt(汉化注释版)
> 🌐 本文件由 [neovim/neovim](https://github.com/neovim/neovim) 翻译注释,英文原版见原项目。
#
# 说明:仅新增/翻译注释,构建逻辑与上游保持一致。
# ============================================================
# CMAKE 参考资料
#   - 入门: https://codingnest.com/basic-cmake/
#   - 最佳实践 (3.0+): https://gist.github.com/mbinna/c61dbb39bca0e4fb7d1f73b0d66a4fd1
#   - 常见坑: https://izzys.casa/2019/02/everything-you-never-wanted-to-know-about-cmake/
#   - 排障:
#     - variable_watch https://cmake.org/cmake/help/latest/command/variable_watch.html
#     - 详细输出: cmake --build build --verbose

# 最低版本要求需与 .github/workflows/build.yml 中测试过的 CMAKE_URL 保持一致。
cmake_minimum_required(VERSION 3.16)

project(nvim C)

# CMP0135:ExternalProject 下载内容的文件时间戳策略,显式设为 NEW 保证可复现
if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
endif()

# Xcode 生成器不受支持,直接报错终止
if(XCODE)
  message(FATAL_ERROR [[Xcode generator is not supported. Use "Ninja" or "Unix Makefiles" instead]])
endif()

# 挂上本项目自带的 CMake 模块目录
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

include(CheckCCompilerFlag)
include(CheckCSourceCompiles)
include(CheckLibraryExists)
include(ExternalProject)
include(FindPackageHandleStandardArgs)
include(GNUInstallDirs)

include(Deps)
include(Find)
include(InstallHelpers)
include(PreventInTreeBuilds)
include(Util)

if(NOT PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  # 非 in-tree 构建时,在 build 目录自动生成 .gitignore,防止构建产物入库。
  file(GENERATE OUTPUT .gitignore CONTENT "*")
endif()

#-------------------------------------------------------------------------------
# 用户设置(User settings)
#-------------------------------------------------------------------------------

if(NOT DEPS_IGNORE_SHA)
  # 是否跳过依赖源的 hash 校验(离线/本地路径构建时用)
  set(DEPS_IGNORE_SHA FALSE)
endif()

#-------------------------------------------------------------------------------
# 变量(Variables)
#-------------------------------------------------------------------------------
# 函数数据 / 触碰标记 / libvterm 测试输出等中间产物的路径
set(FUNCS_DATA ${PROJECT_BINARY_DIR}/funcs_data.mpack)
set(TOUCHES_DIR ${PROJECT_BINARY_DIR}/touches)
set(VTERM_TEST_FILE ${PROJECT_BINARY_DIR}/test/vterm_test_output)

# 收集 runtime/doc 下全部文档;CONFIGURE_DEPENDS 让新增文件自动触发重配置
file(GLOB DOCFILES CONFIGURE_DEPENDS ${PROJECT_SOURCE_DIR}/runtime/doc/*.txt)

# CI 上保留安装输出便于排查;本地静默安装信息
if(NOT CI_BUILD)
  set(CMAKE_INSTALL_MESSAGE NEVER)
endif()

# 老 CMake(<3.20)默认导出 compile_commands.json,方便 clangd 等工具
if(${CMAKE_VERSION} VERSION_LESS 3.20)
  set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
endif()

# 3.26+ 用增量复制的 copy_directory_if_different,减少运行时目录拷贝开销
if(${CMAKE_VERSION} VERSION_GREATER_EQUAL 3.26)
  set(COPY_DIRECTORY copy_directory_if_different)
else()
  set(COPY_DIRECTORY copy_directory)
endif()

# 优先使用本项目 bundled 的依赖版本。
if(DEFINED ENV{DEPS_BUILD_DIR})
  set(DEPS_PREFIX "$ENV{DEPS_BUILD_DIR}/usr" CACHE PATH "Path prefix for finding dependencies")
else()
  set(DEPS_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/.deps/usr" CACHE PATH "Path prefix for finding dependencies")
  # 在 CLion 或 Visual Studio 里打开时,自动构建 bundled 依赖。
  if(NOT EXISTS ${DEPS_PREFIX}
     AND (DEFINED ENV{CLION_IDE}
          OR DEFINED ENV{VisualStudioEdition}))
    message(STATUS "Building dependencies...")
    # 用与主构建一致的工具链/编译选项单独配置一份依赖构建树
    set(DEPS_BUILD_DIR ${PROJECT_BINARY_DIR}/.deps)
    file(MAKE_DIRECTORY ${DEPS_BUILD_DIR})
    execute_process(
      COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR}
        -D CMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -D CMAKE_C_COMPILER=${CMAKE_C_COMPILER}
        -D CMAKE_C_FLAGS=${CMAKE_C_FLAGS}
        -D CMAKE_C_FLAGS_DEBUG=${CMAKE_C_FLAGS_DEBUG}
        -D CMAKE_C_FLAGS_MINSIZEREL=${CMAKE_C_FLAGS_MINSIZEREL}
        -D CMAKE_C_FLAGS_RELWITHDEBINFO=${CMAKE_C_FLAGS_RELWITHDEBINFO}
        -D CMAKE_C_FLAGS_RELEASE=${CMAKE_C_FLAGS_RELEASE}
        -D CMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
        ${PROJECT_SOURCE_DIR}/cmake.deps
      WORKING_DIRECTORY ${DEPS_BUILD_DIR})
    execute_process(
      COMMAND ${CMAKE_COMMAND} --build ${DEPS_BUILD_DIR}
        --config ${CMAKE_BUILD_TYPE})
    set(DEPS_PREFIX ${DEPS_BUILD_DIR}/usr)
  endif()
endif()

# 把 bundled 依赖前缀插到查找路径最前,优先于系统库
list(INSERT CMAKE_PREFIX_PATH 0 ${DEPS_PREFIX})

if(APPLE)
  # 未手动设置 macOS 部署目标(经 $MACOSX_DEPLOYMENT_TARGET)时,
  # 回退为本机系统版本。此处与 cmake.deps 都要设置。
  if(NOT CMAKE_OSX_DEPLOYMENT_TARGET)
    execute_process(COMMAND sw_vers -productVersion
                    OUTPUT_VARIABLE MACOS_VERSION
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "${MACOS_VERSION}")
  endif()
  message(STATUS "Using deployment target ${CMAKE_OSX_DEPLOYMENT_TARGET}")
endif()

if(WIN32 OR APPLE)
  # Handle case-insensitive filenames for Windows and Mac.
  set(CASE_INSENSITIVE_FILENAME TRUE)
endif()

if (MINGW)
  # Disable LTO by default as it may not compile
  # See https://github.com/Alexpux/MINGW-packages/issues/3516
  # and https://github.com/neovim/neovim/pull/8654#issuecomment-402316672
  option(ENABLE_LTO "enable link time optimization" OFF)
else()
  option(ENABLE_LTO "enable link time optimization" ON)
endif()
option(ENABLE_LIBINTL "enable libintl" ON)
option(ENABLE_UNIBILIUM "enable unibilium" ON)
option(ENABLE_WASMTIME "enable wasmtime" OFF)

message(STATUS "CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}")

set_default_buildtype(Debug)
get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(NOT isMultiConfig)
  # Unlike build dependencies in cmake.deps, we want dev dependencies such as
  # Uncrustify to always be built with Release.
  list(APPEND DEPS_CMAKE_ARGS -D CMAKE_BUILD_TYPE=Release)
endif()

# If not in a git repo (e.g., a tarball) these tokens define the complete
# version string, else they are combined with the result of `git describe`.
set(NVIM_VERSION_MAJOR 0)
set(NVIM_VERSION_MINOR 13)
set(NVIM_VERSION_PATCH 0)
set(NVIM_VERSION_PRERELEASE "-dev") # for package maintainers

# API level
set(NVIM_API_LEVEL 15)        # Bump this after any API/stdlib change.
set(NVIM_API_LEVEL_COMPAT 0)  # Adjust this after a _breaking_ API change.
set(NVIM_API_PRERELEASE true)

# We _want_ assertions in RelWithDebInfo build-type.
if(CMAKE_C_FLAGS_RELWITHDEBINFO MATCHES DNDEBUG)
  string(REPLACE "-DNDEBUG" "-DRELDEBUG" CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}")
  string(REPLACE "/DNDEBUG" "/DRELDEBUG" CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}")
  string(REPLACE "  " " " CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}") # Remove duplicate whitespace
endif()

option(ENABLE_ASAN_UBSAN "Enable Clang address & undefined behavior sanitizer for nvim binary." OFF)
option(ENABLE_MSAN "Enable Clang memory sanitizer for nvim binary." OFF)
# TSAN exists to test Luv threads.
option(ENABLE_TSAN "Enable Clang thread sanitizer for nvim binary." OFF)

if((ENABLE_ASAN_UBSAN AND ENABLE_MSAN)
    OR (ENABLE_ASAN_UBSAN AND ENABLE_TSAN)
    OR (ENABLE_MSAN AND ENABLE_TSAN))
  message(FATAL_ERROR "Sanitizers cannot be enabled simultaneously")
endif()

# Place targets in bin/ or lib/ for all build configurations
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
foreach(CFGNAME ${CMAKE_CONFIGURATION_TYPES})
  string(TOUPPER ${CFGNAME} CFGNAME)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CFGNAME} ${CMAKE_BINARY_DIR}/bin)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CFGNAME} ${CMAKE_BINARY_DIR}/lib)
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${CFGNAME} ${CMAKE_BINARY_DIR}/lib)
endforeach()

if(NOT PREFER_LUA)
  find_program(LUA_PRG NAMES luajit)
endif()
find_program(LUA_PRG NAMES lua5.1 lua5.2 lua)
mark_as_advanced(LUA_PRG)
if(NOT LUA_PRG)
  message(FATAL_ERROR "Failed to find a Lua 5.1-compatible interpreter")
endif()
message(STATUS "Using Lua interpreter: ${LUA_PRG}")

# Some of the code generation still relies on stable table ordering in order to
# produce reproducible output - specifically the msgpack'ed data in
# funcs_metadata.generated.h and ui_events_metadata.generated.h. This should
# ideally be fixed in the generators, but until then as a workaround you may provide
# a specific lua implementation that provides the needed stability by setting LUA_GEN_PRG:
if(NOT LUA_GEN_PRG)
  set(LUA_GEN_PRG "${LUA_PRG}" CACHE FILEPATH "Path to the lua used for code generation.")
endif()
mark_as_advanced(LUA_GEN_PRG)
message(STATUS "Using Lua interpreter for code generation: ${LUA_GEN_PRG}")

option(COMPILE_LUA "Pre-compile Lua sources into bytecode (for sources that are included in the binary)" ON)

# Lint
option(CI_LINT "Abort if lint programs not found" OFF)
if(CI_LINT)
  set(LINT_REQUIRED "REQUIRED")
endif()
find_program(SHELLCHECK_PRG shellcheck ${LINT_REQUIRED})
mark_as_advanced(SHELLCHECK_PRG)
find_program(STYLUA_PRG stylua ${LINT_REQUIRED})
mark_as_advanced(STYLUA_PRG)
find_program(TS_QUERY_LS_PRG ts_query_ls ${LINT_REQUIRED})
mark_as_advanced(TS_QUERY_LS_PRG)

set(STYLUA_DIRS runtime scripts src test contrib)

add_glob_target(
  TARGET lintlua-stylua
  COMMAND ${STYLUA_PRG}
  FLAGS --color=always --check --respect-ignores
  GLOB_DIRS ${STYLUA_DIRS}
  GLOB_PAT *.lua
  TOUCH_STRATEGY PER_DIR)
# Special handling of some files (which are ignored in .styluaignore).
# Workaround because stylua doesn't(?) support file-specific settings.
add_custom_target(lintlua-stylua2
  COMMAND ${STYLUA_PRG} --config-path "${PROJECT_SOURCE_DIR}/.stylua2.toml"
    --color=always --check
    "${PROJECT_SOURCE_DIR}/test/functional/ui/decorations_spec.lua"
    "${PROJECT_SOURCE_DIR}/test/functional/ui/float_spec.lua"
    "${PROJECT_SOURCE_DIR}/test/functional/ui/multigrid_spec.lua"
)
add_dependencies(lintlua-stylua lintlua-stylua2)

add_custom_target(lintlua)
add_dependencies(lintlua lintlua-stylua)

add_glob_target(
  TARGET lintsh
  COMMAND ${SHELLCHECK_PRG}
  FLAGS -x -a
  GLOB_DIRS scripts
  GLOB_PAT *.sh
  TOUCH_STRATEGY PER_DIR)

add_custom_target(lintquery-compilation
  COMMAND ${TS_QUERY_LS_PRG}
  check ${PROJECT_SOURCE_DIR}/runtime/queries --config
  '{"parser_install_directories": ["${DEPS_PREFIX}/lib/nvim/parser"]}')

add_custom_target(lintquery-format
  COMMAND ${TS_QUERY_LS_PRG}
  format ${PROJECT_SOURCE_DIR}/runtime/queries --check)

add_custom_target(lintquery)
add_dependencies(lintquery lintquery-compilation lintquery-format)

add_custom_target(lintcommit
  COMMAND $<TARGET_FILE:nvim_bin> --clean -l ${PROJECT_SOURCE_DIR}/scripts/lintcommit.lua main)
add_dependencies(lintcommit nvim_bin)

add_custom_target(linterrcodes
  COMMAND $<TARGET_FILE:nvim_bin> --clean -l ${PROJECT_SOURCE_DIR}/scripts/linterrcodes.lua
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
add_dependencies(linterrcodes nvim_bin)

add_custom_target(lint)
add_dependencies(lint lintc lintlua lintsh lintquery)

# Format
add_glob_target(
  TARGET formatlua
  COMMAND ${STYLUA_PRG}
  FLAGS --respect-ignores
  GLOB_DIRS ${STYLUA_DIRS}
  GLOB_PAT *.lua
  TOUCH_STRATEGY PER_DIR)
# Special handling of some files (which are ignored in .styluaignore).
# Workaround because stylua doesn't(?) support file-specific settings.
add_custom_target(formatlua2
  COMMAND ${STYLUA_PRG} --config-path "${PROJECT_SOURCE_DIR}/.stylua2.toml"
    "${PROJECT_SOURCE_DIR}/test/functional/ui/decorations_spec.lua"
    "${PROJECT_SOURCE_DIR}/test/functional/ui/float_spec.lua"
    "${PROJECT_SOURCE_DIR}/test/functional/ui/multigrid_spec.lua"
)
add_dependencies(formatlua formatlua2)

add_custom_target(formatquery
  COMMAND ${TS_QUERY_LS_PRG}
  format ${PROJECT_SOURCE_DIR}/runtime/queries)

add_custom_target(format)
add_dependencies(format formatc formatlua formatquery)

install_helper(
  FILES ${CMAKE_SOURCE_DIR}/src/man/nvim.1
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1)

add_custom_target(nvim ALL)
add_dependencies(nvim nvim_bin nvim_runtime_deps nvim_runtime)

add_subdirectory(src/nvim)
add_subdirectory(src/tee)
add_subdirectory(src/xxd)
add_subdirectory(cmake.config)
add_subdirectory(runtime)
add_subdirectory(test)

add_custom_target(uninstall
  COMMAND ${CMAKE_COMMAND} -P ${PROJECT_SOURCE_DIR}/cmake/UninstallHelper.cmake)

if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
  add_subdirectory(cmake.packaging)
endif()

get_externalproject_options(uncrustify ${DEPS_IGNORE_SHA})
ExternalProject_Add(uncrustify
  DOWNLOAD_DIR ${DEPS_DOWNLOAD_DIR}/uncrustify
  CMAKE_ARGS ${DEPS_CMAKE_ARGS}
    -D CMAKE_RUNTIME_OUTPUT_DIRECTORY=${DEPS_BIN_DIR}
    -D CMAKE_SKIP_RPATH=true
  EXCLUDE_FROM_ALL TRUE
  ${EXTERNALPROJECT_OPTIONS})

if (CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "arm|aarch|ARM")
  set(EMMYLUA_ARCH arm64)
else()
  set(EMMYLUA_ARCH x64)
endif()

string(TOLOWER ${CMAKE_HOST_SYSTEM_NAME} EMMYLUA_SYSTEM)
set(EMMYLUA_ARCHIVE_EXT tar.gz)
set(EMMYLUA_EXE_EXT "")
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
  if(EMMYLUA_ARCH STREQUAL "arm64")
    set(EMMYLUA_ARCH aarch64)
  endif()
  string(APPEND EMMYLUA_ARCH "-glibc.2.17")
elseif(CMAKE_HOST_WIN32)
  set(EMMYLUA_SYSTEM win32)
  set(EMMYLUA_ARCHIVE_EXT zip)
  set(EMMYLUA_EXE_EXT .exe)
endif()

set(EMMYLUA_VERSION 0.25.1)
set(EMMYLUA_ARCHIVE "emmylua_check-${EMMYLUA_SYSTEM}-${EMMYLUA_ARCH}.${EMMYLUA_ARCHIVE_EXT}")
set(EMMYLUA_URL https://github.com/EmmyLuaLs/emmylua-analyzer-rust/releases/download/${EMMYLUA_VERSION}/${EMMYLUA_ARCHIVE})

ExternalProject_Add(download_emmylua
  URL ${EMMYLUA_URL}
  DOWNLOAD_DIR ${DEPS_DOWNLOAD_DIR}/emmylua
  SOURCE_DIR ${DEPS_BIN_DIR}/emmylua
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  EXCLUDE_FROM_ALL TRUE
  DOWNLOAD_NO_PROGRESS TRUE
  CMAKE_CACHE_ARGS ${DEPS_CMAKE_CACHE_ARGS})

add_custom_target(emmylua-check
  COMMAND ${DEPS_BIN_DIR}/emmylua/emmylua_check${EMMYLUA_EXE_EXT}
    ${PROJECT_SOURCE_DIR}/runtime
    --config ${PROJECT_SOURCE_DIR}/.emmyrc.json
    --warnings-as-errors
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
  USES_TERMINAL
  VERBATIM)

add_dependencies(emmylua-check download_emmylua)
