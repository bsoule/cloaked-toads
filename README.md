
An Omniauth strategy for Epson 

Configure like this in config/initializers/omniauth.rb (or wherever you're intializing of course):

``` ruby

Rails.application.config.middleware.use OmniAuth::Builder do
      provider :epson, clientId, clientsecret, 
                       :scope => 'gps.run',         
                       :client_options => {
                          :authorize_url => epsonAuthURL, 
                          :token_url => epsonTokenURL 
                       }
```
