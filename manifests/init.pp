class webserver (
        $httpd_version = "installed",
        $php_version = "installed"
    ) {

    # Virtual Resources that may or may not be defined elsewhere
    @package { "httpd":
        ensure => $httpd_version
    }

    @service { "httpd":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => [
            File["/etc/httpd/conf/httpd.conf"],
            File["/etc/httpd/local.d/"],
            File["/etc/httpd/includes.d/admin.conf"],
            File["/etc/httpd/includes.d/aliases.conf"],
            File["/etc/httpd/includes.d/do-not-bloat-httpd.conf"],
            File["/etc/httpd/includes.d/listen.conf"],
            File["/etc/httpd/includes.d/virtualhost.conf"],
            File["/etc/httpd/modules-enabled/"],
            File["/etc/httpd/sites-enabled/"],
            Package["httpd"]
        ]
    }

    @file { [
            "/etc/pki/",
            "/etc/pki/tls/",
            "/etc/pki/tls/certs/",
            "/etc/pki/tls/private/"
        ]:
        ensure => directory
    }

    file { "/etc/httpd/local.d/":
        ensure => directory,
        recurse => false,
        require => Package["httpd"]
    }

    # Definitely manage those
    file { [
            "/etc/httpd/configs.d/",
            "/etc/httpd/includes.d/",
            "/etc/httpd/modules-enabled/",
            "/etc/httpd/sites-enabled/"
        ]:
        ensure => directory,
        recurse => true,
        purge => true,
        force => true,
        require => Package["httpd"]
    }

    file { "/etc/httpd/conf.d/":
        ensure => absent,
        recurse => true,
        purge => true,
        force => true,
        require => Package["httpd"]
    }

    # The master httpd.conf file
    file { "/etc/httpd/conf/httpd.conf":
        source => $::httpd_version ? {
            /^2\.4\./ => [
                    "puppet://$server/private/$environment/webserver/httpd24.conf.$hostname",
                    "puppet://$server/private/$environment/webserver/httpd24.conf.$groupname",
                    "puppet://$server/private/$environment/webserver/httpd24.conf",
                    "puppet://$server/files/webserver/httpd24.conf.$hostname",
                    "puppet://$server/files/webserver/httpd24.conf.$groupname",
                    "puppet://$server/files/webserver/httpd24.conf",
                    "puppet://$server/modules/webserver/httpd24.conf.$hostname",
                    "puppet://$server/modules/webserver/httpd24.conf.$groupname",
                    "puppet://$server/modules/webserver/httpd24.conf"
                ],
            default => [
                "puppet://$server/private/$environment/webserver/httpd.conf.$hostname",
                "puppet://$server/private/$environment/webserver/httpd.conf.$groupname",
                "puppet://$server/private/$environment/webserver/httpd.conf",
                "puppet://$server/files/webserver/httpd.conf.$hostname",
                "puppet://$server/files/webserver/httpd.conf.$groupname",
                "puppet://$server/files/webserver/httpd.conf",
                "puppet://$server/modules/webserver/httpd.conf.$hostname",
                "puppet://$server/modules/webserver/httpd.conf.$groupname",
                "puppet://$server/modules/webserver/httpd.conf"
            ]
        },
        require => Package["httpd"],
        notify => Service["httpd"]
    }

    ##
    ## Different types of "modules"
    ##
    ## "modules" in this manifest goes to whatever you can "yum install" and is
    ## pluggable (so includes webapplications like "php" and "phpMyAdmin")
    ##
    ## Different types of modules are:
    ##
    ## module_stock:
    ##
    ##      Stock modules that come with the httpd package. You dont need them
    ##      all, but the defaults just so happen to load them all anyway :/
    ##
    ## module_package:
    ##
    ##      Packages that provide modules for httpd, such as "mod_python".
    ##      Again, you dont need them all, and these are only applied when
    ##      enabled.
    ##
    ## module_application:
    ##
    ##      Packages such as "mrtg", "php", "phpMyAdmin", etc.
    ##
    ## Enable or include such modules as follows (if at all you want them
    ## managed by Puppet):
    ##
    ## node 'node1.example.org' {
    ##     include webserver
    ##
    ##     webserver::module::enable { ["mod_python"] }
    ## }
    ##

    # Get the list of available modules to httpd with:
    # yum list | grep ^mod_ | cut -d'.' -f 1 | sort
    #
    @webserver::module_package { [
            "mod_annodex",
            "mod_auth_kerb",
            "mod_auth_mysql",
            "mod_auth_ntlm_winbind",
            "mod_auth_pam",
            "mod_auth_pgsql",
            "mod_auth_shadow",
            "mod_authn_sasl",
            "mod_authz_ldap",
            "mod_bw",
            "mod_cband",
            "mod_dav_svn",
            "mod_dnssd",
            "mod_evasive",
            "mod_extract_forwarded",
            "mod_fcgid",
            "mod_fcgid-selinux",
            "mod_geoip",
            "mod_line_edit",
            "mod_mono",
            "mod_nss",
            "mod_perl",
            "mod_perl-devel",
            "mod_revocator",
            "mod_security",
            "mod_speedycgi",
            "mod_ssl",
            "mod_suphp",
            "mod_wsgi"
        ]:
        enable => true
    }

    @webserver::module_package { [
            "mod_python"
        ]:
        enable => $os ? {
            "Fedora" => $osmajorver ? {
                "17" => true,
                default => false
            },
            default => true
        }
    }

    # These modules include the version number in their configuration,
    # so these are templates.
    @webserver::module_package { "mod_passenger":
        enable => true,
        template => "module_mod_passenger.erb"
    }

    @webserver::module_package { "php":
        enable => true,
        ensure => $php_version,
        template => "module_php.erb"
    }

    # These modules are *not* available on <= EL-4
    webserver::module_stock { [
            "mod_auth_basic",
            "mod_authn_file",
            "mod_authn_anon",
            "mod_authn_dbm",
            "mod_authz_host",
            "mod_authz_user",
            "mod_authz_owner",
            "mod_authz_groupfile",
            "mod_authz_dbm",
            "mod_proxy_ajp",
            "mod_proxy_balancer"
        ]:
        enable => $os ? {
            "CentOS" => $osmajorver ? {
                "4" => false,
                default => true
            },
            "RedHat" => $osmajorver ? {
                "4" => false,
                default => true
            },
            default => true
        }
    }

    # These modules are only available on EL-4
    webserver::module_stock { [
            "mod_access",
            "mod_auth_anon",
            "mod_auth_dbm",
            "mod_auth_ldap"
        ]:
        enable => $os ? {
            "CentOS" => $osmajorver ? {
                "4" => true,
                default => false
            },
            "RedHat" => $osmajorver ? {
                "4" => true,
                default => false
            },
            default => false
        }
    }

    # These modules are *not* available on <= EL-4, and not on F-18
    @webserver::module_stock { [
            "mod_ldap",
            "mod_authn_alias",
            "mod_authn_default",
            "mod_authnz_ldap",
            "mod_authz_default"
        ]:
        enable => $os ? {
            "CentOS" => $osmajorver ? {
                "4" => false,
                default => true
            },
            "RedHat" => $osmajorver ? {
                "4" => false,
                default => true
            },
            "Fedora" => $osmajorver ? {
                "17" => true,
                default => false,
            },
            default => true
        }
    }

    # These modules are not available on F-18
    @webserver::module_stock { [
            "mod_disk_cache",
        ]:
        enable => $os ? {
            "Fedora" => $osmajorver ? {
                "17" => true,
                default => false
            },
            default => true
        }
    }

    @webserver::module_stock { [
            "mod_authn_core",
            "mod_authz_core",
            "mod_cgi",
            "mod_socache_shmcb"
        ]:
        enable => true
    }

    @webserver::module_stock { [
            "mod_slotmem_shm",
            "mod_unixd"
        ]:
        enable => true
    }

    # These modules are only available on F-18
    webserver::module_stock { [
            "mod_mpm_prefork",
            "mod_systemd",
        ]:
        enable => $os ? {
            "Fedora" => $osmajorver ? {
                "17" => false,
                default => true
            },
            default => false
        }
    }

    webserver::module_stock { [
            "mod_actions",
            "mod_alias",
            "mod_autoindex",
            "mod_auth_digest",
            "mod_cache",
            "mod_dav",
            "mod_dav_fs",
            "mod_dir",
            "mod_deflate",
            "mod_env",
            "mod_expires",
            "mod_ext_filter",
            "mod_headers",
            "mod_include",
            "mod_info",
            "mod_log_config",
            "mod_logio",
            "mod_mime",
            "mod_mime_magic",
            "mod_negotiation",
            "mod_proxy",
            "mod_proxy_connect",
            "mod_proxy_ftp",
            "mod_proxy_http",
            "mod_rewrite",
            "mod_setenvif",
            "mod_speling",
            "mod_status",
            "mod_suexec",
            "mod_userdir",
            "mod_usertrack",
            "mod_vhost_alias"
        ]:
        enable => true
    }

    webserver::module_stock { [
            "mod_file_cache",
            "mod_mem_cache"
        ]:
        enable => false
    }

    # Get the list of available webapps with:
    # repoquery --queryformat="%{NAME}\n" --whatprovides "/etc/httpd/conf.d/*" | grep -vE "(^$|^mod)" | sort | uniq
    #
    @webserver::module_application { [
            "apcupsd-cgi",
            "awstats",
            "BackupPC",
            "bugzilla",
            "cacti",
            "cobbler",
            "dap-server-cgi",
            "drupal",
            "freeradius-dialupadmin",
            "gallery2",
            "ganglia-web",
            "gitweb",
            "glpi",
            "glpi-mass-ocs-import",
            "glump",
            "horde",
            "htdig-web",
            "httpd",
            "httpd-manual",
            "ipcalculator-cgi",
            "jpoker",
            "koji-hub",
            "koji-web",
            "libapreq2",
            "limph",
            "mailgraph",
            "mailman",
            "mantis-config-httpd",
            "mediawiki",
            "MochiKit",
            "moodle",
            "mrtg",
            "mythweb",
            "nagios",
            "nntpgrab-web",
            "pastebin",
            "perl-HTML-Mason",
            "phpldapadmin",
            "phpMyAdmin",
            "phpPgAdmin",
            "phpTodo",
            "phpwapmail",
            "poker-web",
            "postgresql-pgpoolAdmin",
            "queuegraph",
            "roundcubemail",
            "roundup",
            "rt3",
            "sagator",
            "ser-serweb",
            "squid",
            "squirrelmail",
            "sysusage",
            "tiquit",
            "trac",
            "viewmtn",
            "viewvc",
            "w3c-markup-validator",
            "webalizer",
            "wordpress",
            "wordtrans-web",
            "zabbix-web",
            "zoneminder"
        ]:
        enable => true
    }

    realize(
            Package["httpd"],
            Service["httpd"]
        )

    case ${::httpd_version} {
        /^2\.4\./: {
            webserver::includedfile { [
                    "admin.conf",
                    "aliases.conf",
                    "do-not-bloat-httpd.conf",
                    "listen.conf",
                    "virtualhost.conf"
                ]:
            }
        }
        default: {
            webserver::includedfile { [
                    "admin.conf",
                    "aliases.conf",
                    "do-not-bloat-httpd.conf",
                    "listen.conf"
                ]:
            }
        }
}

