# $module_name/lib/puppet/provider/tmpfile/bash.rb
Puppet::Type.type(:tmpfile).provide(:bash) do

  def self.instances
    things = `for i in $(find /tmp/ -maxdepth 1 -type f -printf "%f\n"); do echo "$i,\"$(cat /tmp/$i | tr '\n' ',')\""; done 2> /dev/null`.split("\n")
    things.collect do |thing|
      myhash           = {}
      myhash[:ensure]  = :present
      myhash[:name]    = `echo #{thing} | cut -d ',' -f1 | tr -d '\n'`
      myhash[:insides] = `echo #{thing} | cut -d ',' -f2 | tr -d '\n'`
      myhash[:extras]  = `echo #{thing} | cut -d ',' -f3 | tr -d '\n'`
      new(myhash)
    end
  end

  def self.prefetch(resources)
    things = instances
    resources.keys.each do |thing|
      if provider = things.find{ |t| t.name == thing }
        resources[thing].provider = provider
      end
    end
  end

  mk_resource_methods

  def insides=(value)
    Puppet.debug("README: setting insides to '#{value}'")
    `echo #{value} > /tmp/#{@resource[:name]}`
    @property_hash[:insides] = value
  end

  def create()
    Puppet.debug("README: echo -e \"#{@resource[:insides]}\\n#{@resource[:extras]}\" > /tmp/#{@resource[:name]}")
    `echo -e "#{@resource[:insides]}\n#{@resource[:extras]}" > /tmp/#{@resource[:name]}`
    @property_hash[:ensure]  = :present
    @property_hash[:insides] = @resource[:insides]
    @property_hash[:extras]  = @resource[:extras]
  end

  def destroy()
    Puppet.debug("README: rm /tmp/#{@resource[:name]}")
    `rm /tmp/#{@resource[:name]}`
    @property_hash[:ensure] = :absent
  end

  def exists?()
    if @property_hash[:ensure] == :present
      Puppet.debug("README: tmpfile #{@resource[:name]} exists")
      return true
    else
      return false
    end
  end

end
