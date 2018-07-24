# IpManager

**Pre-requisites for testing**
    1. In IPAM check Administration > phpipam settings > turn API & also IP request module to ON > save.
    2. Go to Administration > API > Add new API key > create an App ID such as 'sbg' > set App Permissions to 'read/Write/Admin' > 
    set App Security to none > click Edit (to save)
    3. Each subnet has 'Ip Requests' set to 'no' as default. This needs changing to Yes.


**Using docker with IP_Manager**
1. git clone ssh://git@stash.skybet.net:7999/ph/ip-manager.git 

2. Check /lib/ip_manager/sbgipmanager.rb for authentication details

3. docker build --rm . -t docker.artifactory.euw.platformservices.io/infra/ph/sbg_ip_manager
 
4. docker push docker.artifactory.euw.platformservices.io/infra/ph/sbg_ip_manager
  
5. docker run -t --rm docker.artifactory.euw.platformservices.io/infra/ph/sbg_ip_manager:latest 'create' 'APP_SPORTSBOOK_SRV02' 'TestHostname' 'Physical Hosting'