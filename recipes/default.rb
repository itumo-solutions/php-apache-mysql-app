#
# Cookbook:: app_1
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
include_recipe 'web_server::default'

passwords = data_bag_item('passwords', 'mysql')

# Create a path to the SQL file in the Chef cache.
create_tables_script_path = ::File.join(Chef::Config[:file_cache_path], 'create-tables.sql')

# Write the SQL script to the filesystem.
cookbook_file create_tables_script_path do
  source 'create-tables.sql'
end

# Seed the database with a table and test data.
execute "initialize #{node['web_server']['database']['dbname']} database" do
  command "mysql -h 127.0.0.1 -u #{node['web_server']['database']['admin_username']} -p#{passwords['itumo_admin']} -D #{node['web_server']['database']['dbname']} < #{create_tables_script_path}"
  not_if  "mysql -h 127.0.0.1 -u #{node['web_server']['database']['admin_username']} -p#{passwords['itumo_admin']} -D #{node['web_server']['database']['dbname']} -e 'describe customers;'"
end

# Write the home page.
template "#{node['web_server']['web']['document_root']}/index.php" do
  source 'index.php.erb'
  variables(
    servername: '127.0.0.1',
    admin_password: passwords['itumo_admin']
  )
end
