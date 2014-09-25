class webserver::ssl inherits webserver {
    realize(Package["httpd"],Service["httpd"])

    if defined(Webserver::Module_package["mod_ssl"]) {
        Webserver::Module_package["mod_ssl"] {
            enable => true
        }
    } else {
        @webserver::module_package { "mod_ssl":
            enable => true
        }
    }

    if (!defined(Webserver::Module_stock["mod_socache_shmcb"])) {
        webserver::module_stock { [
                "mod_socache_shmcb"
            ]:
            enable => $os ? {
                "Fedora" => $osmajorver ? {
                    "17" => false,
                    default => true
                },
                default => false
            }
        }
    } else {
        Webserver::Module_stock["mod_socache_shmcb"] {
            enable => $os ? {
                "Fedora" => $osmajorver ? {
                    "17" => false,
                    default => true
                },
                default => false
            }
        }

        realize(Webserver::Module_stock["mod_socache_shmcb"])
    }

    realize(Webserver::Module_package["mod_ssl"])
}
