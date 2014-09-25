define webserver::virtualhost(
            $enable = true,
            $certificate = false,
            $template = false,
            $namevirtualhost_ip = "*",
            $namevirtualhost_port = "80",
            $servername = "localhost.localdomain",
            $serveradmin = "root@localhost.localdomain",
            $filename = false,
            $documentroot = "/var/www/html",
            $nagios_check = false,
            $webalizer = false,
            $webalizer_dir = false
        ) {

    include webserver

    case $template {
        false: {
            file { "/etc/httpd/sites-enabled/$name.conf":
                path => $filename ? {
                    false => "/etc/httpd/sites-enabled/$name.conf",
                    default => "/etc/httpd/sites-enabled/$filename"
                },
                ensure => file,
                owner => "root",
                group => "root",
                mode => "644",
                source => [
                    "puppet://$server/private/$environment/webserver/sites/$name.conf.$hostname",
                    "puppet://$server/private/$environment/webserver/sites/$name.conf",
                    "puppet://$server/files/webserver/sites/$name.conf.$hostname",
                    "puppet://$server/files/webserver/sites/$name.conf",
                    "puppet://$server/modules/webserver/sites/$name.conf.$hostname",
                    "puppet://$server/modules/webserver/sites/$name.conf"
                ],
                notify => Service["httpd"]
            }
        }
        default: {
            file { "/etc/httpd/sites-enabled/$name.conf":
                path => $filename ? {
                    false => "/etc/httpd/sites-enabled/$name.conf",
                    default => "/etc/httpd/sites-enabled/$filename"
                },
                ensure => file,
                owner => "root",
                group => "root",
                mode => "644",
                content => template($template),
                notify => Service["httpd"]
            }
        }
    }

    case $certificate {
        true: {
            realize(
                    File["/etc/pki/"],
                    File["/etc/pki/tls/"],
                    File["/etc/pki/tls/certs/"],
                    File["/etc/pki/tls/private/"],
                    Webserver::Module_package["mod_ssl"]
                )

            file { "/etc/pki/tls/certs/$name.cert":
                source => [
                    "puppet://$server/private/$environment/webserver/sites/$name.cert",
                    "puppet://$server/files/webserver/sites/$name.cert",
                    "puppet://$server/modules/webserver/sites/$name.cert"
                ],
                owner => "root",
                group => "root",
                mode => "644",
                notify => Service["httpd"]
            }

            file { "/etc/pki/tls/private/$name.key":
                source => [
                    "puppet://$server/private/$environment/webserver/sites/$name.key",
                    "puppet://$server/files/webserver/sites/$name.key",
                    "puppet://$server/modules/webserver/sites/$name.key"
                ],
                owner => "root",
                group => "apache",
                mode => "640",
                notify => Service["httpd"]
            }

            if !defined(File["/etc/pki/tls/certs/$name.ca.cert"]) {
                file { "/etc/pki/tls/certs/$name.ca.cert":
                    source => [
                        "puppet://$server/private/$environment/webserver/sites/$name.ca.cert",
                        "puppet://$server/files/webserver/sites/$name.ca.cert",
                        "puppet://$server/modules/webserver/sites/$name.ca.cert"
                    ],
                    owner => "root",
                    group => "root",
                    mode => "644",
                    notify => Service["httpd"]
                }
            }
        }
    }

    case $nagios_check {
        true: {
            @@nagios_service { "check_http_$name":
                check_command => "check_http!100.0,20%!500.0,60%",
                use => "web-service",
                host_name => "$fqdn",
                notification_period => "24x7",
                service_description => "$name",
                tag => "$domain"
            }
        }
    }

    case $webalizer {
        true: {
            if defined(File["/etc/webalizer/"]) {
                realize(File["/etc/webalizer/"])
            } else {
                @file { "/etc/webalizer/":
                    ensure => directory,
                    owner => "root",
                    group => "root",
                    mode => "755"
                }
                realize(File["/etc/webalizer/"])
            }

            if defined(Package["webalizer"]) {
                realize(Package["webalizer"])
            } else {
                @package { "webalizer":
                    ensure => installed
                }
                realize(Package["webalizer"])
            }

            if defined(Cron["webalizer"]) {
                realize(Cron["webalizer"])
            } else {
                @cron { "webalizer":
                    command => 'find /etc/webalizer/ -type f -exec webalizer -c {} \; >>/var/log/webalizer.log 2>&1',
                    hour => "*/3",
                    minute => "0",
                    require => Package["webalizer"]
                }
                realize(Cron["webalizer"])
            }

            file { "/etc/webalizer/$name.conf":
                owner => "root",
                group => "root",
                mode => "644",
                source => [
                    "puppet://$server/private/$environment/webserver/webalizer/$name.conf.$hostname",
                    "puppet://$server/private/$environment/webserver/webalizer/$name.conf",
                    "puppet://$server/files/webserver/webalizer/$name.conf.$hostname",
                    "puppet://$server/files/webserver/webalizer/$name.conf",
                    "puppet://$server/modules/webserver/webalizer/webalizer.conf"
                ]
            }

            if $webalizer_dir {
                if !defined(File["/var/www/"]) {
                    file { "/var/www/": ensure => directory }
                }
                if !defined(File["/var/www/$domain/"]) {
                    file { "/var/www/$domain/": ensure => directory }
                }
                if !defined(File["/var/www/$domain/$hostname/"]) {
                    file { "/var/www/$domain/$hostname/": ensure => directory }
                }
                if !defined(File["/var/www/$domain/$hostname/public_html/"]) {
                    file { "/var/www/$domain/$hostname/public_html/": ensure => directory }
                }
                if !defined(File["/var/www/$domain/$hostname/public_html/usage/"]) {
                    file { "/var/www/$domain/$hostname/public_html/usage/": ensure => directory }
                }
                if !defined(File["/var/www/$domain/$hostname/public_html/usage/$name/"]) {
                    file { "/var/www/$domain/$hostname/public_html/usage/$name/": ensure => directory }
                }
            }
        }
    }
}
