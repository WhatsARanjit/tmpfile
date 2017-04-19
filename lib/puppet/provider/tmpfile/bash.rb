# $module_name/lib/puppet/provider/tmpfile/bash.rb
Puppet::Type.type(:tmpfile).provide(:bash) do

  def initialize(value={})
    super(value)

    @flushme  = {}
    @do_flush = true
  end

  def self.instances
    things   = []
    tmpfiles = Dir['/tmp/*'].select { |f| File.file?(f) }
    tmpfiles.each do |file|
      contents = File.read(file).split("\n")
      things << {
        'name'    => file.gsub(/^\/tmp\//,''),
        'insides' => contents[0],
        'extras'  => contents[1],
      }
    end
    things.collect do |thing|
      myhash           = {}
      myhash[:ensure]  = :present
      myhash[:name]    = thing['name']
      myhash[:insides] = thing['insides']
      myhash[:extras]  = thing['extras']
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
    Puppet.debug("README: Writing /tmp/#{@resource[:name]}")
    File.open("/tmp/#{@resource[:name]}", 'w') { |file| file.write("#{@resource[:insides]}\n#{@resource[:extras]}\n") }
    @property_hash[:ensure]  = :present
    @property_hash[:insides] = @resource[:insides]
    @property_hash[:extras]  = @resource[:extras]
  end

  def destroy()
    @do_flush = false
    Puppet.debug("README: Deleting /tmp/#{@resource[:name]}")
    File.delete("/tmp/#{@resource[:name]}")
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
      File.open("/tmp/#{@resource[:name]}", 'w') { |file| file.write("#{insides_value}\n#{extras_value}\n") }

      # Don't forget to update @property_hash
      @property_hash[:insides] = insides_value
      @property_hash[:extras]  = extras_value
    end
  end

end
