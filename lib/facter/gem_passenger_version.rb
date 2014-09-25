require 'facter'
Facter.add(:gem_passenger_version) do
    setcode do %x{rpmquery --qf='%{VERSION}' rubygem-passenger} end
end

