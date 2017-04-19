# $module_name/lib/puppet/provider/tmpfile/bash.rb
Puppet::Type.type(:tmpfile).provide(:bash) do

  def self.instances
    things = `ls /tmp 2> /dev/null`.split("\n")
    things.collect do |thing|
      myhash          = {}
      myhash[:ensure] = :present
      myhash[:name]   = thing
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

  def create()
    Puppet.debug("README: touch /tmp/#{@resource[:name]}")
    `touch /tmp/#{@resource[:name]}`
    @property_hash[:ensure] = :present
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
