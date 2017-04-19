# $module_name/lib/puppet/provider/tmpfile/bash.rb
Puppet::Type.type(:tmpfile).provide(:bash) do

  def initialize(value={})
    super(value)

    @flushme  = {}
    @do_flush = true
  end

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
    @flushme['insides'] = value
  end

  def extras=(value)
    Puppet.debug("README: setting extras to '#{value}'")
    `echo #{value} > /tmp/#{@resource[:name]}`
    @flushme['extras'] = value
  end

  def create()
    @do_flush = false
    Puppet.debug("README: echo -e \"#{@resource[:insides]}\\n#{@resource[:extras]}\" > /tmp/#{@resource[:name]}")
    `echo -e "#{@resource[:insides]}\n#{@resource[:extras]}" > /tmp/#{@resource[:name]}`
    @property_hash[:ensure]  = :present
    @property_hash[:insides] = @resource[:insides]
    @property_hash[:extras]  = @resource[:extras]
  end

  def destroy()
    @do_flush = false
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

  def flush()
    if @do_flush
      insides_value = @flushme['insides'] || @property_hash[:insides]
      extras_value  = @flushme['extras']  || @property_hash[:extras]
      `echo -e "#{insides_value}\n#{extras_value}" > /tmp/#{@resource[:name]}`

      # Don't forget to update @property_hash
      @property_hash[:insides] = insides_value
      @property_hash[:extras]  = extras_value
    end
  end

end
