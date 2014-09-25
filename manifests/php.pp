class webserver::php inherits webserver {
    realize(Package["httpd"], Webserver::Module_application["php"], Webserver::Module_application["php-zts"])
}

