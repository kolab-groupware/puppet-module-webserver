define webserver::includedfile($enable = true) {
    if (!defined(File["/etc/httpd/includes.d/$name"])) {
        file { "/etc/httpd/includes.d/$name":
            ensure => $enable ? {
                true => file,
                default => absent
            },
            source => [
                "puppet://$server/private/$environment/webserver/includes.d/$name.$hostname",
                "puppet://$server/private/$environment/webserver/includes.d/$name",
                "puppet://$server/private/$environment/webserver/conf.d/$name.$hostname",
                "puppet://$server/private/$environment/webserver/conf.d/$name",
                "puppet://$server/files/webserver/includes.d/$name.$hostname",
                "puppet://$server/files/webserver/includes.d/$name",
                "puppet://$server/files/webserver/conf.d/$name.$hostname",
                "puppet://$server/files/webserver/conf.d/$name",
                "puppet://$server/modules/webserver/includes.d/$name"
            ],
            require => File["/etc/httpd/includes.d/"],
            notify => Service["httpd"]
        }
    }
}

