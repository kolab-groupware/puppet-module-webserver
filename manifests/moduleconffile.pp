define webserver::moduleconffile($enable = true, $template = false) {

    case $enable {
        false: {
            file { "/etc/httpd/modules-enabled/$name":
                ensure => absent
            }
        }
        default: {
            case $template {
                false: {
                    file { "/etc/httpd/modules-enabled/$name":
                        owner => "root",
                        group => "root",
                        mode => "644",
                        source => [
                            "puppet://$server/private/$environment/webserver/modules/$name.$hostname",
                            "puppet://$server/private/$environment/webserver/modules/$name",
                            "puppet://$server/files/webserver/modules/$name.$hostname",
                            "puppet://$server/files/webserver/modules/$name",
                            "puppet://$server/modules/webserver/modules/$name.$hostname",
                            "puppet://$server/modules/webserver/modules/$name"
                        ],
                        notify => Service["httpd"]
                    }
                }
                default: {
                    file { "/etc/httpd/modules-enabled/$name":
                        owner => "root",
                        group => "root",
                        mode => "644",
                        content => template("webserver/$template"),
                        notify => Service["httpd"]
                    }
                }
            }
        }
    }
}

