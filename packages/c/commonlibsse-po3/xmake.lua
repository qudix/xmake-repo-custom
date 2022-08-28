package("commonlibsse-po3")
    set_homepage("https://github.com/powerof3/CommonLibSSE")
    set_description("A reverse engineered library for Skyrim Special Edition.")
    set_license("MIT")

    add_urls("https://github.com/powerof3/CommonLibSSE.git")

    add_configs("xbyak", {description = "Enable trampoline support for Xbyak", default = false, type = "boolean"})
    add_configs("ae", {description = "Enable support for Skyrim AE", default = false, type = "boolean"})

    add_deps("binary_io", "boost", "spdlog")

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
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")

        local configs = {}
        configs.xbyak = package:config("xbyak")
        configs.ae = package:config("ae")

        import("package.tools.xmake").install(package, configs)
    end)
