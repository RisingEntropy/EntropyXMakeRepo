package("ncnn_compile")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Tencent/ncnn")
    set_description("ncnn is a high-performance neural network inference framework optimized for the mobile platform")
    set_license("BSD-3-Clause")


    add_versions("20240102", "743c08f71c532f76a6342eb8f65fc845ce730b614a5c2fa6eb727ac2db664407")

    if is_plat("windows") then 
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MT", readonly = true})
    end

    add_urls("https://github.com/Tencent/ncnn/releases/download/$(version)/ncnn-$(version)-full-source.zip")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean"})
    add_configs("gpu", {description = "Use GPU build", default = false, type = "boolean"})
    add_deps("cmake")

    if is_plat("linux") then 
        add_deps("glslang")
    end


    add_includedirs("include")


    on_load("windows", function (package)
        package:add("deps", "protobuf-cpp")
    end)

    on_install("windows|x64", "macosx|x86_64", "linux", function (package)
        local configs = {}
        table.insert(configs, "-DNCNN_VULKAN="..(package:config("gpu") and "ON" or "OFF"))
        
        if package:config("shared") then
            table.insert(configs, "--DNCNN_SHARED_LIB=ON")
        end

        if package:is_plat("windows") then 
            table.insert(configs, "-Dprotobuf_DIR=third_party/protobuf/cmake/install.cmake")
        end 

        import("package.tools.cmake").install(package, configs)
        if package:is_plat("windows") then
            os.trycp("vc143.pdb", package:installdir("lib"))
        end
    end)
package_end()