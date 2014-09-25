define webserver::module_package(
            $enable = true,
            $ensure = "installed",
            $template = false
        ) {

    if defined(Webserver::Moduleconffile["$name.conf"]) {
        Webserver::Moduleconffile["$name.conf"] {
            enable => $enable,
            template => $template
        }
    } else {
        @webserver::moduleconffile { "$name.conf":
            enable => $enable,
            template => $template
        }
    }

    if defined(Package["$name"]) {
        Package["$name"] {
            ensure => $enable ? {
                true => $ensure,
                default => absent
            }
        }
    } else {
        @package { "$name":
            ensure => $enable ? {
                true => $ensure,
                default => absent
            }
        }
    }

    realize(
            Webserver::Moduleconffile["$name.conf"],
            Package["$name"]
        )
}

