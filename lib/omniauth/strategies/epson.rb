require 'omniauth-oauth2'
require 'multi_json'


module OmniAuth
  module Strategies
    class Epson < OmniAuth::Strategies::OAuth2

      # Give your strategy a name.
      option :name, "epson"
      option :provider_ignores_state, false

      option :token_params, {
        :token_method => :post,
        :grant_type => "authorization_code"
      }

      option :client_options, {
        :site => "https://test-sensing.epsonconnect.com",
      }

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid do
        raw_info["subject_id"]
      end

      def callback_url
        options.client_options[:callback_url] || (full_host + script_name + callback_path)
      end      
      
      def authorize_params
        options.authorize_params[:state] = SecureRandom.hex(24)
        params = options.authorize_params.merge(options.authorize_options.inject({}){|h,k| h[k.to_sym] = options[k] if options[k]; h})
        session['omniauth.state'] = params[:state]
puts session['omniauth.state']
        params
      end 


      def request_phase
        ap = authorize_params
        scope = ap.delete :scope
        url = client.auth_code.authorize_url({:redirect_uri => callback_url}.merge(ap))
        redirect url+"&scope=#{scope}"
      end

=begin # removing this on Feb 24th:
      def callback_phase
        state = session.delete('omniauth.state')
        if request.params['error_reason'] || request.params['error']
          fail!(error, CallbackError.new(request.params['error'], request.params['error_description'] || request.params['error_reason'], request.params['error_uri']))
        elsif ( !options.provider_ignores_state && 
              ( request.params['state'].to_s.empty? || 
                request.params['state'] != state 
              ) 
        )
          fail!(:csrf_detected, CallbackError.new(:csrf_detected, 'CSRF detected'))
        else
          super
        end
      rescue ::OAuth2::Error, CallbackError => e
        fail!(:invalid_credentials, e)
      rescue ::MultiJson::DecodeError => e
        fail!(:invalid_response, e)
      rescue ::Timeout::Error, ::Errno::ETIMEDOUT, Faraday::Error::TimeoutError => e
        fail!(:timeout, e)
      rescue ::SocketError, Faraday::Error::ConnectionFailed => e
        fail!(:failed_to_connect, e)
      end
=end

      def raw_info
        @raw_info ||= access_token.params
      end

    protected
      # v1.1.2
      def build_access_token
        client.auth_code.get_token(
          request.params['code'], {
            :redirect_uri => callback_url,
            :headers => {
              "Authorization" => 
              "Basic " + 
              Base64.strict_encode64("#{client.id}:#{client.secret}")
            }
          }.merge( token_params.to_hash(:symbolize_keys => true) ))
      end

    end
  end
end


