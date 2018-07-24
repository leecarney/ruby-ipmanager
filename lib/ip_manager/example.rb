require 'ip_manager'

method = ARGV[0]
subnet_target = ARGV[1] # e.g. APP_SPORTSBOOK_SRV02
hostname_tag = ARGV[2] # e.g. TestHostname
owner_tag = ARGV[3] # e.g. Physical Hosting

case method

when "create"

  IpManager.api_base = "https://ipam.test8.skybet.net/api/sbg"
  IpManager.api_username = 'sbg1'
  IpManager.api_password = 'bingobingo'

  IpManager.auth

  IpManager::IpAddress.allocate_ip(
      :subnet_target => subnet_target,
      :hostname_tag => hostname_tag,
      :owner_tag => owner_tag,
  )
else
  puts 'Method not found' # Add user instructions here for fail
end


