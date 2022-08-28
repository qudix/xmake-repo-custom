package("luau")
    set_homepage("https://github.com/Roblox/luau")
    set_description("A fast, small, safe, gradually typed embeddable scripting language derived from Lua.")
    set_license("MIT")

    add_urls("https://github.com/Roblox/luau/archive/$(version).zip",
             "https://github.com/Roblox/luau.git")
    add_versions("0.542", "e2f794ec46bd08fa179d797ede85bcc2feef5bfc741cb4a15b9c7738e3c6556a")

    add_configs("cli", { description = "Build CLI", default = false, type = "boolean" })
    add_configs("tests", { description = "Build tests", default = false, type = "boolean" })
    add_configs("web", { description = "Build Web module", default = false, type = "boolean" })
    add_configs("werror", { description = "Warnings as errors", default = false, type = "boolean" })
    add_configs("externc", { description = "Use extern C for all APIs", default = false, type = "boolean" })

    on_install("windows|x64", "linux|x64", "macosx|x64", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")

        local configs = {}
        configs.cli = package:config("cli")
        configs.tests = package:config("tests")
        configs.web = package:config("web")
        configs.werror = package:config("werror")
        configs.externc = package:config("externc")

        import("package.tools.xmake").install(package, configs)
    end)
