require 'omniauth-oauth2'
require 'multi_json'


module OmniAuth
  module Strategies
    class Epson < OmniAuth::Strategies::OAuth2

      # Give your strategy a name.
      option :name, "epson"

      #option :base_url, "https://test-sensing.epsonconnect.com" 

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        :site => "https://test-sensing.epsonconnect.com",
        :authorize_url => "https://test-sensing.epsonconnect.com/account/oauth2/authorize.html",
        :token_url => "https://test-api.sensing.epsonconnect.com/oauth2/auth/token",
        :callback_url=> "https://www.beeminder.com/auth/epson/callback"
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

      def callback_url
        options.client_options[:callback_url] || super
      end      


      def request_phase
        url = client.auth_code.authorize_url({:redirect_uri => callback_url}.merge(authorize_params))
        log :info, "info! #{url}"
        log :debug, "debug! #{url}"
        puts "puts! #{url}"
        log :info, options.inspect
        log :debug, options.inspect
        puts options.inspect
        redirect url
      end

      def callback_phase
        log :info, request.params.inspect
        log :debug, request.params.inspect
        puts request.params.inspect
        error = request.params['error_reason'] || request.params['error']
        if error
          log :info, request.params['error']
          log :debug, request.params['error']
          puts request.params['error']
          fail!(error, CallbackError.new(request.params['error'], request.params['error_description'] || request.params['error_reason'], request.params['error_uri']))
        elsif !options.provider_ignores_state && (request.params['state'].to_s.empty? || request.params['state'] != session.delete('omniauth.state'))
          log :info, "Fail! CSRF detected!"
          log :debug, "Fail! CSRF detected!"
          puts "Fail! CSRF detected!"
          fail!(:csrf_detected, CallbackError.new(:csrf_detected, 'CSRF detected'))
        else
          log :info, "success on request phase"
          log :debug, "success on request phase"
          puts "success on request phase"
          self.access_token = build_access_token
          self.access_token = access_token.refresh! if access_token.expired?
          log :info, self.access_token.inspect
          log :debug, self.access_token.inspect
          puts self.access_token.inspect
          super
        end
      rescue ::OAuth2::Error, CallbackError => e
        log :info, "invalid credentials"
        fail!(:invalid_credentials, e)
      rescue ::MultiJson::DecodeError => e
        log :info, "MultiJson decode error"
        fail!(:invalid_response, e)
      rescue ::Timeout::Error, ::Errno::ETIMEDOUT, Faraday::Error::TimeoutError => e
        log :info, "Timeout error"
        fail!(:timeout, e)
      rescue ::SocketError, Faraday::Error::ConnectionFailed => e
        log :info, "Timeout/Socket error"
        fail!(:failed_to_connect, e)
      end

      def raw_info
        @raw_info #||= access_token.get('/api/v1/people/me.json').parsed
      end
    end
  end
end


