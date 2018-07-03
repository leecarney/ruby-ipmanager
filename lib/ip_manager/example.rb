require 'ip_manager'

def request_ip
  # Example to configure credentials, attempt to authorise & then create a single new Ip address
  # with tagged data for owner and hostname

  IpManager.api_base = "https://ipam.test6.skybet.net/api/sbg"
  IpManager.api_username = 'sbg1'
  IpManager.api_password = 'bingobingo'

  IpManager.auth

  IpManager::IpAddress.allocate_ip(
      :subnet_target => 'APP_SPORTSBOOK_SRV02',
      :hostname_tag => 'TestHostname',
      :owner_tag => 'Physical Hosting',
      )
end


request_ip

