define webserver::module_stock($enable = true) {
    if defined(Webserver::Moduleconffile["$name.conf"]) {
        Webserver::Moduleconffile["$name.conf"] {
            enable => $enable
        }
    } else {
        @webserver::moduleconffile { "$name.conf":
            enable => $enable
        }
    }

    realize(Webserver::Moduleconffile["$name.conf"])
}
