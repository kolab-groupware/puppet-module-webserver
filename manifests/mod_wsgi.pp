class webserver::mod_wsgi inherits webserver {
    realize(Package["httpd"],Service["httpd"])

    if defined(Webserver::Module_package["mod_wsgi"]) {
        Webserver::Module_package["mod_wsgi"] {
            enable => true
        }
    } else {
        @webserver::module_package { "mod_wsgi":
            enable => true
        }
    }

    realize(Webserver::Module_package["mod_wsgi"])
}

