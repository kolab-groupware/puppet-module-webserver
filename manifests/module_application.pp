##
## A module_application is an application that
## can be installed once, but used many times. One
## example is phpMyAdmin, which can be used by as many
## different VirtualHosts as you want. However, since
## those applications often have just one config.inc.php,
## you may or may not need to copy the application tree
## onto the location where it is going to be used.
##
## Anyway, the module_application type as you can see enables
## the installation of the appropriate package, puts a
## config file in /etc/httpd/conf.d/$name.conf, and optionally copies the
## application tree over to the location of $web_path (or
## DocumentRoot/../ by default).
##
define webserver::module_application(  $enable = true,
                            $site_source = false,
                            $domain_name = false,
                            $site_name = false,
                            $packagename = false,
                            $modulename = false,
                            $web_path = "/") {

    $real_packagename = $packagename ? {
        false => $name,
        default => $packagename
    }

    $real_modulename = $modulename ? {
        false => $name,
        default => $modulename
    }

    if defined(Package["$real_packagename"]) {
        if $enable {
            Package["$real_packagename"] {
                ensure => installed
            }
        }
        realize(Package["$real_packagename"])
    } else {
        @package { "$real_packagename":
            ensure => $enable ? {
                true => installed,
                default => absent
            }
        }
        realize(Package["$real_packagename"])
    }

    if defined(Webserver::Configdfile["$real_modulename.conf"]) {
        Webserver::Configdfile["$real_modulename.conf"] {
            enable => $enable
        }
        realize(Webserver::Configdfile["$real_modulename.conf"])
    } else {
        @webserver::configdfile { "$real_modulename.conf":
            enable => $enable,
        }
        realize(Webserver::Configdfile["$real_modulename.conf"])
    }

    case $site_source {
        false: {}
        default: {
            case $domain_name {
                false: {}
                default: {
                    case $site_name {
                        false: {}
                        default: {
                            case $web_path {
                                "/": {
                                    file { "/data/www/$domain_name/$site_name/$real_modulename/":
                                        ensure => directory,
                                        source => "$site_source"
                                    }
                                }
                                default: {
                                    file { "/data/www/$domain_name/$site_name/$real_modulename/$web_path/":
                                        ensure => directory,
                                        source => "$site_source"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
