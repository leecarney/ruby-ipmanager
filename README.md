# IpManager

**Pre-requisites for testing**
    1. Inside ip_manager/docker > run docker-compose up -d
    2. Open http://127.0.0.1 and complete setup
    3. Once logged in, go to Administration > phpipam settings > turn API & also IP request module to ON > save.
    4. Go to Administration > API > Add new API key > create an App ID such as 'sbg' > set App Permissions to 'read/Write/Admin' > 
    set App Security to none > click Edit (to save)
    5. Each subnet has 'Ip Requests' set to 'no' as default. This needs changing to Yes.

**For development:**
    run rake install
    then,
    ruby example.rb

**To get started**
    look at example.rb

**For config:**
    IpManager.api_base = "http://127.0.0.1/api/sbg/"
    IpManager.api_username = 'Admin'
    IpManager.api_password = "password"

**For authentication (to retrieve a token):**
    IpManager.auth
