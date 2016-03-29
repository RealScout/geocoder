require 'geocoder/lookups/base'
require 'geocoder/results/esri_address_candidates'

module Geocoder::Lookup
  class EsriAddressCandidates < Base

    def name
      'EsriAddressCandidates'
    end

    def query_url(query)
      search_keyword = query.reverse_geocode? ? 'reverseGeocode' : 'findAddressCandidates'

      "#{protocol}://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/#{search_keyword}?" +
        url_query_string(query)
    end

    def set_token(expiration=20160)
      # store token as instance variable
      # token cleared on any api error
      return @token if @token.present?

      response = Net::HTTP.post_form URI('https://www.arcgis.com/sharing/rest/oauth2/token'),
        f: 'json',
        client_id: configuration.api_key[0],
        client_secret: configuration.api_key[1],
        grant_type: 'client_credentials',
        expiration: expiration

      response = JSON.parse(response.body)
      if response['error'].present?
        @token = nil
        raise RuntimeError "failed to obtain token: #{response['error'].fetch('error_description', 'unknown error')}"
      end
      @token = response['access_token']
    end

    private # ---------------------------------------------------------------

    def results(query)
      return [] unless doc = fetch_data(query)

      if (doc['error'].present?)
        @token = nil
        raise_error(Geocoder::Error, doc['error'])
      end

      if (!query.reverse_geocode?)
        doc['candidates'] || []
      else
        [doc]
      end

    end

    def query_url_params(query)
      params = {
        :f => 'pjson',
        :outFields => '*'
      }
      if query.reverse_geocode?
        params[:location] = query.coordinates.reverse.join(',')
      else
        params[:Address] = query.sanitized_text
      end

      params.merge!(super)

      if params[:forStorage] == 'true' && params[:token].blank?
        params[:token] = set_token
      end

      params
    end

  end
end
