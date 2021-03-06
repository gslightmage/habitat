hab_sup 'default'

ruby_block 'wait-for-sup-default-startup' do
  block do
    raise unless system('hab sup status')
  end
  retries 30
  retry_delay 1
end

hab_service 'skylerto/splunkforwarder'

# we need this sleep to let splunkforwarder start and for the hab supervisor to
# recognize this and write the state file out otherwise our functional
# tests fail.
ruby_block 'wait-for-splunkforwarder-start' do
  block do
    sleep 3
  end
  action :nothing
  subscribes :run, 'hab_service[skylerto/splunkforwarder]', :immediately
end

hab_service 'skylerto/splunkforwarder unload' do
  service_name 'skylerto/splunkforwarder'
  action :unload
end

hab_service 'ncr_devops_platform/sensu-agent-win' do
  strategy 'rolling'
  channel :stable
  action :load
end

# we need this sleep to let sensu-agent-win start and for the hab supervisor to
# recognize this and write the state file out otherwise our functional
# tests fail.
ruby_block 'wait-for-sensu-agent-win-start' do
  block do
    sleep 5
  end
  action :nothing
  subscribes :run, 'hab_service[ncr_devops_platform/sensu-agent-win]', :immediately
end

hab_service 'ncr_devops_platform/sensu-agent-win stop' do
  service_name 'ncr_devops_platform/sensu-agent-win'
  action :stop
end
