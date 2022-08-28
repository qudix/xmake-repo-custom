package("binary_io")
    set_homepage("https://github.com/Ryan-rsm-McKenzie/binary_io")
    set_description("A binary i/o library for C++, without the agonizing pain.")
    set_license("MIT")

    add_urls("https://github.com/Ryan-rsm-McKenzie/binary_io/archive/$(version).zip",
             "https://github.com/Ryan-rsm-McKenzie/binary_io.git")
    add_versions("2.0.5", "306a288d2dce59e57e9382330a652ac4b85d993da649beda702881667f5dc20c")

    add_configs("tests", { description = "Build tests", default = false, type = "boolean" })

    add_deps("cmake")

    on_load("windows|x64", "linux|x64", function (package)
        if package:config("tests") then
            package:add("deps", "catch2")
        end
    end)

    on_install("windows|x64", "linux|x64", function (package)
        local configs = {
            "-DBINARY_IO_BUILD_DOCS:BOOL=OFF",
            "-DBUILD_TESTING:BOOL=" .. (package:config("tests") and "ON" or "OFF")
        }

        if is_plat("windows") then
            table.insert(configs, "-DCMAKE_CXX_FLAGS:STRING=/EHsc /MP /W4 /WX")
            table.insert(configs, "-DCMAKE_EXE_LINKER_FLAGS_RELEASE:STRING=/DEBUG:FASTLINK")
            table.insert(configs, "-DCMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
        elseif is_plat("linux") then
            table.insert(configs, "-DCMAKE_CXX_FLAGS:STRING=-fno-sanitize-recover=undefined -fsanitize=address,undefined -pedantic -pedantic-errors -Wall -Werror -Wextra --coverage")
            table.insert(configs, "-DCMAKE_EXE_LINKER_FLAGS_RELEASE:STRING=-fno-sanitize-recover=undefined -fsanitize=address,undefined --coverage")
            table.insert(configs, "-CMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON")
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("binary_io::exception(\"\")",
            { includes = "binary_io/binary_io.hpp", configs = { languages = "c++20" } }
        ))
    end)
