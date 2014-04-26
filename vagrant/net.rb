def network(vm, name)
  bridge = load(name + '_bridge', 'wlan0')
  ip = load(name + '_ip', 'dhcp')
  if ip == 'dhcp'
      vm.network name+"_network", type: :dhcp, :bridge => bridge
  elsif ip != 'none'
      vm.network name+"_network", ip: ip, :bridge => bridge
  end
end
