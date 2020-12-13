# IpManager

This links to the open source IP Manager project PHPIPAM

**Pre-requisites for testing**
    1. In IPAM check Administration > phpipam settings > turn API & also IP request module to ON > save.
    2. Go to Administration > API > Add new API key > create an App ID such as 'MyIP' > set App Permissions to 'read/Write/Admin' > 
    set App Security to none > click Edit (to save)
    3. Each subnet has 'Ip Requests' set to 'no' as default. This needs changing to Yes.


**Using docker with IP_Manager**
1. git clone ip-manager.git 

2. Check /lib/ip_manager/myipmanager.rb for authentication details

3. docker build --rm . -t my_ip_manager
 
4. docker push my_ip_manager
  
5. docker run -t --rm my_ip_manager:latest 'create' 'New IP' 'TestHostname' 'IP Hosting'