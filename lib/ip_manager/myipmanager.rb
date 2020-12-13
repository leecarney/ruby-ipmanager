require 'ip_manager'

action = ARGV[0]
subnet_target = ARGV[1] # e.g. HOST_SERVER
hostname_tag = ARGV[2] # e.g. TestHostname
owner_tag = ARGV[3] # e.g. IP Hosting

case method

when "create"

  IpManager.api_base = "https://phpipam/api/"
  IpManager.api_username = 'user'
  IpManager.api_password = 'password'

  IpManager.auth

  IpManager::IpAddress.allocate_ip(
      :subnet_target => subnet_target,
      :hostname_tag => hostname_tag,
      :owner_tag => owner_tag,
  )
else
  puts 'Action not found' # Add user instructions here for fail
end


