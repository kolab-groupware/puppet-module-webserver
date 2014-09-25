define webserver::configdfile($enable = true) {
    file { "/etc/httpd/configs.d/$name":
        ensure => $enable ? {
            true => file,
            default => absent
        },
        source => [
            "puppet://$server/private/$environment/webserver/configs.d/$name.$hostname",
            "puppet://$server/private/$environment/webserver/configs.d/$name",
            "puppet://$server/private/$environment/webserver/conf.d/$name.$hostname",
            "puppet://$server/private/$environment/webserver/conf.d/$name",
            "puppet://$server/files/webserver/configs.d/$name.$hostname",
            "puppet://$server/files/webserver/configs.d/$name",
            "puppet://$server/files/webserver/conf.d/$name.$hostname",
            "puppet://$server/files/webserver/conf.d/$name",
            "puppet://$server/modules/webserver/configs.d/$name"
        ],
        require => File["/etc/httpd/configs.d/"],
        notify => Service["httpd"]
    }
}
