# $module_name/lib/puppet/provider/tmpfile/bash.rb
Puppet::Type.type(:tmpfile).provide(:bash) do

  def create()
    Puppet.debug("README: touch /tmp/#{@resource[:name]}")
    `touch /tmp/#{@resource[:name]}`
  end

  def destroy()
    Puppet.debug("README: rm /tmp/#{@resource[:name]}")
    `rm /tmp/#{@resource[:name]}`
  end

  def exists?()
    `ls /tmp/#{@resource[:name]} 2> /dev/null`
    if $?.exitstatus != 0
      return false
    else
      Puppet.debug("README: tmpfile #{@resource[:name]} exists")
      return true
    end
  end

end
