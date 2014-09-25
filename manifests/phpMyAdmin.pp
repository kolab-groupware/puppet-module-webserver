class webserver::phpMyAdmin inherits webserver {
    include webserver::php
    realize(Package["httpd"], Webserver::Module_application["phpMyAdmin"])
}
