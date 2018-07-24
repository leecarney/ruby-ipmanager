# IpManager

**Pre-requisites for testing**
    1. Inside ip_manager/docker > run docker-compose up -d
    2. Open http://127.0.0.1 and complete setup
    3. Once logged in, go to Administration > phpipam settings > turn API & also IP request module to ON > save.
    4. Go to Administration > API > Add new API key > create an App ID such as 'sbg' > set App Permissions to 'read/Write/Admin' > 
    set App Security to none > click Edit (to save)
    5. Each subnet has 'Ip Requests' set to 'no' as default. This needs changing to Yes.


**Using docker with IP_Manager**

1. docker build --rm . -t docker.artifactory.euw.platformservices.io/infra/ph/sbg_ip_manager
 
2. docker push docker.artifactory.euw.platformservices.io/infra/ph/sbg_ip_manager
  
3. docker run -t --rm docker.artifactory.euw.platformservices.io/infra/ph/sbg_ip_manager:latest 'create' 'APP_SPORTSBOOK_SRV02' 'TestHostname' 'Physical Hosting'