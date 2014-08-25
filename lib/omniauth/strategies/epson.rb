require 'omniauth-oauth2'
require 'multi_json'


module OmniAuth
  module Strategies
    class Epson < OmniAuth::Strategies::OAuth2

      # Give your strategy a name.
      option :name, "epson"

      option :base_url, "https://test-sensing.epsonconnect.com" 

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        :authorize_path => "/account/oauth2/authorize.html",
        :scope=> "gps.run"
      }

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid{ raw_info['id'] }

      info do
        {
          :name => raw_info['name'],
          :email => raw_info['email']
        }
      end

      #extra do
      #  {
      #    'raw_info' => raw_info
      #  }
      #end

      def raw_info
        @raw_info ||= access_token.get('/api/v1/people/me.json').parsed
      end
    end
  end
end


