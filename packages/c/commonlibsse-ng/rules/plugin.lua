rule("plugin")
    add_deps("c++", "win.sdk.resource")

    on_config(function(a_target)
        import("core.project.project")
        import("core.base.semver")

        a_target:set("kind", "shared")
        a_target:set("arch", "x64")

        local get_plugin_conf = function(a_conf)
            return a_target:extraconf("rules", "plugin", a_conf)
        end

        local plugin_name = get_plugin_conf("name") or project.name()
        local plugin_author = get_plugin_conf("author") or ""
        local plugin_email = get_plugin_conf("email") or ""
        local plugin_license = get_plugin_conf("license") or ""
        local plugin_version = get_plugin_conf("version") or project.version()
        local plugin_semver = semver.new(plugin_version)
        local plugin_sources = get_plugin_conf("sources")
        local plugin_options = get_plugin_conf("options") or {}

        a_target:set("basename", plugin_name)

        local config_dir = path.join("$(buildir)", ".config", a_target:name())
        if not os.exists(config_dir) then
            os.mkdir(config_dir)
        end

        local file = io.open(path.join(config_dir, "version.rc"), "w")
        if file then
            file:print("#include <winres.h>")
            file:print("")
            file:print("1 VERSIONINFO")
            file:print("FILEVERSION %s, %s, %s, 0", plugin_semver:major(), plugin_semver:minor(), plugin_semver:patch())
            file:print("PRODUCTVERSION %s, %s, %s, 0", plugin_semver:major(), plugin_semver:minor(), plugin_semver:patch())
            file:print("FILEFLAGSMASK 0x17L")
            file:print("#ifdef _DEBUG")
            file:print("    FILEFLAGS 0x1L")
            file:print("#else")
            file:print("    FILEFLAGS 0x0L")
            file:print("#endif")
            file:print("FILEOS 0x4L")
            file:print("FILETYPE 0x1L")
            file:print("FILESUBTYPE 0x0L")
            file:print("BEGIN")
            file:print("    BLOCK \"StringFileInfo\"")
            file:print("    BEGIN")
            file:print("        BLOCK \"040904b0\"")
            file:print("        BEGIN")
            file:print("            VALUE \"FileDescription\", \"%s\"", plugin_name)
            file:print("            VALUE \"FileVersion\", \"%s.0\"", plugin_version)
            file:print("            VALUE \"InternalName\", \"%s\"", plugin_name)
            file:print("            VALUE \"LegalCopyright\", \"%s, %s\"", plugin_author, plugin_license)
            file:print("            VALUE \"ProductName\", \"%s\"", plugin_name)
            file:print("            VALUE \"ProductVersion\", \"%s.0\"", plugin_version)
            file:print("        END")
            file:print("    END")
            file:print("    BLOCK \"VarFileInfo\"")
            file:print("    BEGIN")
            file:print("        VALUE \"Translation\", 0x409, 1200")
            file:print("    END")
            file:print("END")
            file:close()
        end

        local plugin_option_struct_compat = "SKSE::StructCompatibility::Independent"
        local plugin_option_runtime_compat = "SKSE::VersionIndependence::AddressLibrary"
        if plugin_options then
            local address_library = plugin_options.address_library or true
            local signature_scanning = plugin_options.signature_scanning or false
            if not address_library and signature_scanning then
                plugin_option_runtime_compat = "SKSE::VersionIndependence::SignatureScanning"
            end
        end

        file = io.open(path.join(config_dir, "plugin.cpp"), "w")
        if file then
            file:print("#include <REL/Relocation.h>")
            file:print("#include <SKSE/SKSE.h>")
            file:print("")
            file:print("SKSEPluginInfo(")
            file:print("    .Version = { %s, %s, %s, 0 },", plugin_semver:major(), plugin_semver:minor(), plugin_semver:patch())
            file:print("    .Name = \"%s\"sv,", plugin_name)
            file:print("    .Author = \"%s\"sv,", plugin_author)
            file:print("    .SupportEmail = \"%s\"sv,", plugin_email)
            file:print("    .StructCompatibility = %s,", plugin_option_struct_compat)
            file:print("    .RuntimeCompatibility = %s", plugin_option_runtime_compat)
            file:print(")")
            file:close()
        end

        a_target:add("files", path.join(config_dir, "*.rc"))
        a_target:add("files", path.join(config_dir, "*.cpp"))

        if plugin_sources then
            for _, file in pairs(plugin_sources.files) do
                a_target:add("files", file)
            end

            for _, file in pairs(plugin_sources.headers) do
                a_target:add("headerfiles", file)
            end

            for _, dir in pairs(plugin_sources.includes) do
                a_target:add("includedirs", dir)
            end

            if plugin_sources.pch then
                a_target:set("pcxxheader", plugin_sources.pch)
            end
        end

        a_target:add("defines", "UNICODE", "_UNICODE")

        a_target:add("cxxflags", "/MP", "/permissive-")
        a_target:add("cxxflags",
            "/Zc:alignedNew",
            "/Zc:__cplusplus",
            "/Zc:externConstexpr",
            "/Zc:forScope",
            "/Zc:hiddenFriend",
            "/Zc:preprocessor",
            "/Zc:referenceBinding",
            "/Zc:ternary")
    end)
