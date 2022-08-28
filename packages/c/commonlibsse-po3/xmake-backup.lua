package("commonlibsse-po3")
    set_homepage("https://github.com/powerof3/CommonLibSSE")
    set_description("This is a reverse engineered library for Skyrim Special Edition.")
    set_license("MIT")

    add_urls("https://github.com/powerof3/CommonLibSSE.git")

    add_configs("xbyak", {description = "Enable trampoline support for Xbyak", default = false, type = "boolean"})
    add_configs("ae", {description = "Enable support for Skyrim AE", default = false, type = "boolean"})

    add_deps("cmake", "binary_io", "boost", "spdlog")

    on_load("windows|x64", function (package)
        package:add("defines", "BOOST_STL_INTERFACES_DISABLE_CONCEPTS")
        package:add("defines", "WINVER=0x0601")
        package:add("defines", "_WIN32_WINNT=0x0601")
        if package:config("xbyak") then
            package:add("defines", "SKSE_SUPPORT_XBYAK=1")
        end
        if package:config("ae") then
            package:add("defines", "SKYRIM_SUPPORT_AE=1")
        end
    end)

    on_install("windows|x64", function (package)
        local configs = {"-DCMAKE_CXX_STANDARD:STRING=20"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE:STRING=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS:BOOL=" .. (package:config("shared") and "ON" or "OFF"))
        if is_plat("windows") then
            table.insert(configs, "-DCMAKE_CXX_FLAGS:STRING=/EHsc /MP /W4 /WX /external:W0")
            table.insert(configs, "-DCMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
        end
        table.insert(configs, "-DSKSE_SUPPORT_XBYAK:BOOL=" .. (package:config("xbyak") and "ON" or "OFF"))
        table.insert(configs, "-DSKYRIM_SUPPORT_AE:BOOL=" .. (package:config("ae") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)
