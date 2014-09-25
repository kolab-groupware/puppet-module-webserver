class webserver::mod_python inherits webserver {
    realize(Package["httpd"],Service["httpd"])

    if defined(Webserver::Module_package["mod_python"]) {
        Webserver::Module_package["mod_python"] {
            enable => true
        }
    } else {
        @webserver::module_package { "mod_python":
            enable => true
        }
    }

    realize(Webserver::Module_package["mod_python"])
}

