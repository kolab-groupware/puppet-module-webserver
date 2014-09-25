class webserver::webapplication inherits webserver {
    define mediawiki(   $domain_name = $domain,
                        $site_name = $hostname,
                        $web_path = "/",
                        $proxykey) {

        Webserver::Webapplication["mediawiki"] {
            domain_name => $domain_name,
            site_name => $site_name,
            web_path => $web_path
        }

        realize(Webserver::Webapplication["mediawiki"])

        if defined(File["/var/www/wiki/"]) {
            realize(File["/var/www/wiki/"])
        } else {
            @file { "/var/www/wiki/":
                ensure => directory
            }
            realize(File["/var/www/wiki/"])
        }

        file { "/var/www/wiki/$name/":
            ensure => directory,
            owner => "apache",
            group => "apache",
            require => Package["mediawiki"]
        }

        file { "/var/www/wiki/$name/LocalSettings.php":
            content => template("webserver/mediawiki/LocalSettings.php.erb"),
            owner => 'apache',
            mode => "0600",
            require => File["/var/www/wiki/$name/"]
        }

        file { "/var/www/wiki/$name/index.php":
            owner => 'apache',
            mode => "0644",
            source => "/usr/share/mediawiki/index.php",
            require => File["/var/www/wiki/$name/"]
        }
    }
}

