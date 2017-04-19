# $module_name/lib/puppet/provider/tmpfile/bash.rb
Puppet::Type.type(:tmpfile).provide(:bash) do

  def self.instances
    things = `for i in $(find /tmp/ -maxdepth 1 -type f -printf "%f\n"); do echo "$i,\"$(cat /tmp/$i)\""; done 2> /dev/null`.split("\n")
    things.collect do |thing|
      myhash           = {}
      myhash[:ensure]  = :present
      myhash[:name]    = `echo #{thing} | cut -d ',' -f1 | tr -d '\n'`
      myhash[:insides] = `echo #{thing} | cut -d ',' -f2 | tr -d '\n'`
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

  def insides
    @property_hash[:insides]
  end

  def insides=(value)
    @property_hash[:insides] = value
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
