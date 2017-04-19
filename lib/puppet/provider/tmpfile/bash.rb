# $module_name/lib/puppet/provider/tmpfile/bash.rb
Puppet::Type.type(:tmpfile).provide(:bash) do

  def create()
    `touch /tmp/#{@resource[:name]}`
  end

  def destroy()
    `rm /tmp/#{@resource[:name]}`
  end

  def exists?()
    `ls /tmp/#{@resource[:name]} 2> /dev/null`
    if $?.exitstatus != 0
      return false
    else
      return true
    end
  end

end
