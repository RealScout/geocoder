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

    def self.get_token(client_id, client_secret, expiration=20160)
      response = Net::HTTP.post_form URI('https://www.arcgis.com/sharing/rest/oauth2/token'),
        f: 'json',
        client_id: client_id,
        client_secret: client_secret,
        grant_type: 'client_credentials',
        expiration: expiration

      response = JSON.parse(response.body)
      if response['error'].present?
        raise RuntimeError "failed to obtain token: #{response['error'].fetch('error_description', 'unknown error')}"
      end
      response['access_token']
    end

    private # ---------------------------------------------------------------

    def results(query)
      return [] unless doc = fetch_data(query)

      if (doc['error'].present?)
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
      params.merge(super)
    end

  end
end

