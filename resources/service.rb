#
# Cookbook Name:: zookeeper
# Resource:: service

# Copyright 2016, EverTrue, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

property :service_style,
         String,
         default: 'runit',
         callbacks: {
           'Must be a valid service style' =>
             -> (service_style) { %w(runit upstart sysv systemd exhibitor).include? service_style },
         }
property :install_dir,         String, default: '/opt/zookeeper'
property :conf_dir,            String, default: '/opt/zookeeper/conf'
property :username,            String, default: 'zookeeper'
property :service_actions,     Array, default: [:enable, :start]
property :template_cookbook,   String, default: 'zookeeper'
property :restart_on_reconfig, [true, false], default: false

action :create do
  executable_path = "#{new_resource.install_dir}/bin/zkServer.sh"
  env_path = "#{new_resource.conf_dir}/zookeeper-env.sh"

  case new_resource.service_style
  when 'runit'
    # runit_service does not install runit itself
    include_recipe 'runit'

    runit_service 'zookeeper' do
      default_logger true
      owner          new_resource.username
      group          new_resource.username
      options(
        zk_env:   env_path,
        exec:     executable_path,
        username: new_resource.username
      )
      cookbook       new_resource.template_cookbook
      action         new_resource.service_actions
    end
  when 'upstart'
    template '/etc/init/zookeeper.conf' do
      source 'zookeeper.upstart.erb'
      mode   '0644'
      variables(
        zk_env:   env_path,
        exec:     executable_path,
        username: new_resource.username
      )
      cookbook new_resource.template_cookbook
      notifies :restart, 'service[zookeeper]' if new_resource.restart_on_reconfig
    end

    service 'zookeeper' do
      provider Chef::Provider::Service::Upstart
      supports status: true, restart: true, nothing: true
      action   new_resource.service_actions
    end
  when 'sysv'
    template '/etc/init.d/zookeeper' do
      source 'zookeeper.sysv.erb'
      mode   '0755'
      variables(
        exec:     executable_path,
        username: new_resource.username
      )
      cookbook new_resource.template_cookbook
      notifies :restart, 'service[zookeeper]' if new_resource.restart_on_reconfig
    end

    service_provider = value_for_platform_family(
      'amazon'  => Chef::Provider::Service::Init::Redhat,
      'rhel'    => Chef::Provider::Service::Init::Redhat,
      'default' => Chef::Provider::Service::Init::Debian
    )

    service 'zookeeper' do
      provider service_provider
      supports status: true, restart: true, nothing: true
      action   new_resource.service_actions
    end
  when 'systemd'
    template '/etc/systemd/system/zookeeper.service' do
      source 'zookeeper.systemd.erb'
      mode   '0644'
      variables(
        zk_env:   env_path,
        exec:     executable_path,
        username: new_resource.username
      )
      cookbook new_resource.template_cookbook
      notifies :run, 'execute[systemctl daemon-reload]'
    end

    execute 'systemctl daemon-reload' do
      action :nothing
      command '/bin/systemctl daemon-reload'
      notifies :restart, 'service[zookeeper]' if new_resource.restart_on_reconfig
    end

    service 'zookeeper' do
      provider Chef::Provider::Service::Systemd
      supports status: true, restart: true, nothing: true
      action   new_resource.service_actions
    end
  when 'exhibitor'
    Chef::Log.info 'Assuming Exhibitor will start up Zookeeper.'
  end
end
