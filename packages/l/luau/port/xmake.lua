-- project
set_project("luau")
set_arch("x64")
set_languages("c11", "cxx17")
set_optimize("faster")
add_rules("mode.debug", "mode.release")

-- options
option("cli")
    set_showmenu(true)
    set_default(false)
    set_description("Build CLI")

option("tests")
    set_showmenu(true)
    set_default(false)
    set_description("Build tests")

option("web")
    set_showmenu(true)
    set_default(false)
    set_description("Build Web module")

option("werror")
    set_showmenu(true)
    set_default(false)
    set_description("Warnings as errors")

option("externc")
    set_showmenu(true)
    set_default(false)
    set_description("Use extern C for all APIs")

-- global
if is_plat("windows") then
    -- 1. multi-core complilation, 2. use the portable CRT functions
    add_cxflags("/MP", "/D_CRT_SECURE_NO_WARNINGS")
else
    -- all warnings
    set_warnings("all")
end

if has_config("web") then
    -- add -fexceptions for emscripten to allow exceptions to be caught in c++
    add_cxflags("-fexceptions")
end

if has_config("werror") then
    -- warnings are errors
    set_warnings("error")
end

-- lib targets
target("luau.common")
    set_kind("headeronly")

    add_includedirs("Common/include", { interface = true })
    add_headerfiles("Common/include/(Luau/*.h)")

target("luau.ast")
    set_kind("static")

    add_deps("luau.common")

    add_includedirs("Ast/include", { public = true })
    add_headerfiles("Ast/include/(Luau/*.h)")
    add_files("Ast/src/**.cpp")

    if is_plat("windows") then
        add_ldflags("/NATVIS:$(curdir)/tools/natvis/Ast.natvis")
    end

target("luau.compiler")
    set_kind("static")

    add_deps("luau.ast")

    add_includedirs("Compiler/include", { public = true })
    add_headerfiles("Compiler/include/(Luau/*.h)")
    add_files("Compiler/src/**.cpp")

    if has_config("externc") then
        add_defines("LUACODE_API=extern\"C\"")
    end

target("luau.analysis")
    set_kind("static")

    add_deps("luau.ast")

    add_includedirs("Analysis/include", { public = true })
    add_headerfiles("Analysis/include/(Luau/*.h)")
    add_files("Analysis/src/**.cpp")

    if is_plat("windows") then
        add_ldflags("/NATVIS:$(curdir)/tools/natvis/Analysis.natvis")
    end

target("luau.codegen")
    set_kind("static")

    add_deps("luau.common")

    add_includedirs("CodeGen/include", { public = true })
    add_headerfiles("CodeGen/include/(Luau/*.h)")
    add_files("CodeGen/src/**.cpp")

    if is_plat("windows") then
        add_ldflags("/NATVIS:$(curdir)/tools/natvis/CodeGen.natvis")
    end

target("luau.vm")
    set_kind("static")
    set_languages("cxx11")

    add_deps("luau.common")

    add_includedirs("VM/include", { public = true })
    add_headerfiles("VM/include/*.h")
    add_files("VM/src/**.cpp")
    add_files("VM/src/lvmexecute.cpp", { cxflags = "/d2ssa-pre-" })

    if has_config("externc") then
        add_defines("LUA_USE_LONGJMP=1", "LUA_API=extern\"C\"")
    end

    if is_plat("windows") then
        add_ldflags("/NATVIS:$(curdir)/tools/natvis/VM.natvis")
    end

target("isocline")
    set_kind("static")

    add_deps("luau.common")

    add_includedirs("extern/isocline/include", { public = true })
    add_files("extern/isocline/src/isocline.c")

    if not is_plat("windows") then
        add_cxflags("-Wno-unused-function")
    end

-- cli targets
if has_config("cli") then
    target("luau.repl.cli")
        set_kind("binary")
        set_basename("luau")

        add_deps("luau.compiler", "luau.vm", "isocline")

        add_includedirs("CLI", { private = true })
        add_files("CLI/Repl.cpp", "CLI/ReplEntry.cpp", "CLI/Coverage.cpp",
            "CLI/FileUtils.cpp", "CLI/Flags.cpp", "CLI/Profiler.cpp")

    target("luau.analyze.cli")
        set_kind("binary")
        set_basename("luau-analyze")

        add_deps("luau.analysis")

        add_includedirs("CLI", { private = true })
        add_files("CLI/Analyze.cpp", "CLI/FileUtils.cpp", "CLI/Flags.cpp")

        if is_plat("windows") and is_mode("debug") then
            add_ldflags("/STACK:2097152")
        end

    target("luau.ast.cli")
        set_kind("binary")
        set_basename("luau-ast")

        add_deps("luau.ast", "luau.analysis")

        add_includedirs("CLI", { private = true })
        add_files("CLI/Ast.cpp", "CLI/FileUtils.cpp")

    target("luau.reduce.cli")
        set_kind("binary")
        set_basename("luau-reduce")

        add_deps("luau.common", "luau.ast", "luau.analysis")

        add_includedirs("CLI", { private = true })
        add_files("CLI/Reduce.cpp", "CLI/FileUtils.cpp")
end

-- test targets
if has_config("tests") then
    target("luau.test")
        set_kind("binary")
        set_basename("Luau.UnitTest")

        add_deps("luau.analysis", "luau.compiler", "luau.codegen")

        add_includedirs("tests", "extern", { private = true })
        add_files("tests/main.cpp", "tests/*.test.cpp|Conformance.test.cpp|Repl.test.cpp",
            "tests/TypeInfer.typePacks.cpp", "tests/Fixture.cpp")

        add_defines("DOCTEST_CONFIG_DOUBLE_STRINGIFY")

    target("luau.test.conformance")
        set_kind("binary")
        set_basename("Luau.Conformance")

        add_deps("luau.analysis", "luau.compiler", "luau.vm")

        add_includedirs("tests", "extern", { private = true })
        add_files("tests/main.cpp", "tests/Conformance.test.cpp")

    target("luau.test.cli")
        set_kind("binary")
        set_basename("Luau.CLI.Test")

        add_deps("luau.compiler", "luau.vm", "isocline")

        add_includedirs("tests", "extern", "CLI", { private = true })
        add_files("tests/main.cpp", "tests/Repl.test.cpp", "CLI/Coverage.cpp",
            "CLI/FileUtils.cpp", "CLI/Flags.cpp", "CLI/Profiler.cpp", "CLI/Repl.cpp")
end

-- web target
if has_config("web") then
    -- TODO
end
