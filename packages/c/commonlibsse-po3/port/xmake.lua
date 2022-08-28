
-- project
set_project("CommonLibSSE")

-- set architecture
set_arch("x64")

-- set languages
set_languages("cxx20")

-- add rules
add_rules("mode.debug", "mode.release")

-- set warnings
set_warnings("allextra", "error")

-- set optimization
set_optimize("faster")

-- set policies
set_policy("build.optimization.lto", true)

-- set flags
add_cxflags("/EHsc", "/MP", "/W4", "/WX", "/external:W0")

-- add packages
add_requires("binary_io", "boost", "spdlog")

-- add options
option("xbyak")
    set_default(false)
    set_description("Enable trampoline support for Xbyak")
    add_defines("SKSE_SUPPORT_XBYAK=1")

option("ae")
    set_default(false)
    set_description("Enable support for Skyrim AE")
    add_defines("SKYRIM_SUPPORT_AE=1")

-- targets
target("CommonLibSSE")
    set_kind("static")

    -- add options
    add_options("xbyak", "ae")

    -- add source files
    add_files("src/**.cpp")

    -- add header files
    add_includedirs("include", { public = true })
    add_headerfiles(
        "include/(RE/**.h)",
        "include/(REL/**.h)",
        "include/(SKSE/**.h)"
    )

    -- set precompiled header
    set_pcxxheader("include/SKSE/Impl/PCH.h")

    -- add defines
    add_defines("BOOST_STL_INTERFACES_DISABLE_CONCEPTS")
    add_defines("WINVER=0x0601") -- Windows 7, minimum supported version by Skyrim Special Edition
    add_defines("_WIN32_WINNT=0x0601")

    -- warnings -> errors
    add_cxflags("/we4715") -- `function` : not all control paths return a value

    -- disable warnings
    add_cxflags("/wd4005") -- macro redefinition
    add_cxflags("/wd4061") -- enumerator `identifier` in switch of enum `enumeration` is not explicitly handled by a case label
    add_cxflags("/wd4200") -- nonstandard extension used : zero-sized array in struct/union
    add_cxflags("/wd4201") -- nonstandard extension used : nameless struct/union
    add_cxflags("/wd4265")
    add_cxflags("/wd4266")
    add_cxflags("/wd4371")
    add_cxflags("/wd4514")
    add_cxflags("/wd4582")
    add_cxflags("/wd4583")
    add_cxflags("/wd4623")
    add_cxflags("/wd4625")
    add_cxflags("/wd4626")
    add_cxflags("/wd4710")
    add_cxflags("/wd4711")
    add_cxflags("/wd4820")
    add_cxflags("/wd5026")
    add_cxflags("/wd5027")
    add_cxflags("/wd5045")
    add_cxflags("/wd5053")
    add_cxflags("/wd5204")
    add_cxflags("/wd5220")

    -- add packages
    add_packages("binary_io", "boost", "spdlog")
