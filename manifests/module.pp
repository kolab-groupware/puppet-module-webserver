class webserver::module inherits webserver {
    #
    # You might call on the same webserver::module enable() or disable()
    # more then once, from other modules for example.
    #
    # This is why these types are types, and first check whether something
    # has already been defined (and then toggle the appropriate attribute).
    #
    # Additionally, it let's you re-enable a disabled module.
    #

    define enable() {
        include webserver

        if defined(Webserver::Module_stock["$name"]) {
            realize(Webserver::Module_stock["$name"])
        }

        if defined(Webserver::Module_package["$name"]) {
            realize(Webserver::Module_package["$name"])
        }

        if defined(Webserver::Module_application["$name"]) {
            realize(Webserver::Module_application["$name"])
        }

        case $name {
            "mod_security": {
                file { "/etc/httpd/modsecurity.d/":
                    ensure => directory,
                    source => [
                        "puppet://$server/private/$environment/webserver/modsecurity.d.$hostname/",
                        "puppet://$server/private/$environment/webserver/modsecurity.d/",
                        "puppet://$server/files/webserver/modsecurity.d.$hostname/",
                        "puppet://$server/files/webserver/modsecurity.d/",
                        "puppet://$server/modules/webserver/modsecurity.d/"
                    ],
                    recurse => true,
                    purge => false,
                    notify => Service["httpd"]
                }
            }
        }
    }

    define disable() {
        include webserver

        if defined(Webserver::Module_stock["$name"]) {
            Webserver::Module_stock["$name"] {
                enable => false
            }

            realize(Webserver::Module_stock["$name"])
        }

        if defined(Webserver::Module_package["$name"]) {
            Webserver::Module_package["$name"] {
                enable => false
            }

            realize(Webserver::Module_package["$name"])
        }

        if defined(Webserver::Module_application["$name"]) {
            Webserver::Module_application["$name"] {
                enable => false
            }

            realize(Webserver::Module_application["$name"])
        }
    }
}

