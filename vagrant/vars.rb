# -*- mode: ruby; -*-

@ui = Vagrant::UI::Basic.new()

def load(name, default)
  # TODO Normalize to vagrantfile
  path = "./.vagrant." + name
  if File.file?(path)
    return File.open(path, "rb") { |f| f.read }
  end
  return default
end

def save(name, value)
  File.open("./.vagrant." + name, 'w') {|f| f.write(value) } 
end

def music()
  path = load('music', '')
  if File.directory?(path)
    return path
  end
  while True do
    path = @ui.ask('Path to the music: ')
    if File.directory?(path)
      save('music',path)
      return path
    end
    @ui.info(path+' is not a directory')
  end
end
