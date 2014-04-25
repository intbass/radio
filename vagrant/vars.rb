# -*- mode: ruby; -*-

@ui = Vagrant::UI::Basic.new()

def load(name, default)
  # TODO Normalize to vagrantfile
  path = File.dirname(__FILE__) + "/../.vagrant." + name
  if File.file?(path)
    return File.open(path, "rb") { |f| f.read }
  end
  return default
end

def save(name, value)
  File.open(File.dirname(__FILE__)+"/../.vagrant." + name, 'w') {|f| f.write(value) } 
end

def music()
  path = load('music', '')
  if File.directory?(path)
    return path
  end
  loop do
    path = @ui.ask('Path to the music: ')
    if File.directory?(path)
      save('music',path)
      return path
    end
    @ui.info(path+' is not a directory')
  end
end
