# $module_name/lib/puppet/type/tmpfile.rb
Puppet::Type.newtype(:tmpfile) do
  ensurable()
  newparam(:name, :namevar => true)
  newproperty(:insides)

  newproperty(:extras) do
    munge do |value|
      return upcase(value)
    end
  end
end
