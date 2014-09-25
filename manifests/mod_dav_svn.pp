class webserver::mod_dav_svn inherits webserver {
    if defined(Webserver::Module["mod_dav_svn"]) {
        Webserver::Module["mod_dav_svn"] {
            enable => true
        }
    } else {
        @webserver::module { "mod_dav_svn":
            enable => true
        }
    }

    realize(Webserver::Module["mod_dav_svn"])

    if defined(Webserver::Module["mod_dav"]) {
        Webserver::Module["mod_dav"] {
            enable => true
        }
    } else {
        @webserver::module { "mod_dav":
            enable => true
        }
    }

    realize(Webserver::Module["mod_dav"])
}

