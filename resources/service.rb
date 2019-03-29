# To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html
resource_name :supervisor_service

property :supervisord_executable_path, String, default: lazy { node['supervisor']['supervisord_default_path'] }

action :create do
  poise_service 'supervisor' do
    command(lazy { "#{new_resource.supervisord_executable_path}/supervisord -n -c #{node.run_state['supervisor']['config_file']}" })
  end
end

action :reload do
  Chef::Log.warn('The :reload action has been renamed :reread. Please update your cookbook code for the new action')
  action_reread
end

action :reread do
  execute 'supervisorctl reread' do
    command(lazy { "#{new_resource.supervisord_executable_path}/supervisorctl -c #{node.run_state['supervisor']['config_file']} reread" })
    action :run
    only_if "#{new_resource.supervisord_executable_path}/supervisorctl -c #{node.run_state['supervisor']['config_file']} avail"
  end
end
