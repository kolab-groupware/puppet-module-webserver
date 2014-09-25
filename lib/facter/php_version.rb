require 'facter'

phpversion = nil
if FileTest.exists?("/usr/bin/php")
    phpversion = %x{php -v 2>/dev/null}.split(" ")[1]
else
    phpversion = "0.0.0"
end

Facter.add("phpversion") do
    setcode do
        phpversion
    end
end

Facter.add("phpmversion") do
    phpmversion = nil
    if phpversion != nil
        phpversionsplit = phpversion.split(".")
        phpmversion = phpversionsplit[0]
    end
    setcode do
        phpmversion
    end
end

Facter.add("phpmmversion") do
    phpmmversion = nil
    if phpversion != nil
        phpversionsplit = phpversion.split(".")
        phpmmversion = phpversionsplit[0] + "." + phpversionsplit[1]
    end
    setcode do
        phpmmversion
    end
end

