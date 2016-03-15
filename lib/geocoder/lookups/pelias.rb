require 'geocoder/lookups/base'
require 'geocoder/results/pelias'

module Geocoder::Lookup
  class Pelias < Base
    def initialize
      @endpoint = configuration[:endpoint] || 'localhost'
      super
    end

    def name
      'Pelias'
    end

    def query_url(query)
      query_type = query.reverse_geocode? ? 'reverse' : 'search'
      "#{protocol}://#{@endpoint}/v1/#{query_type}?" + url_query_string(query)
    end

    private

    def query_url_params(query)
      super(query).merge(
          :key => configuration.api_key
      ).merge(super)
    end

    def results(query)
      return [] unless doc = fetch_data(query)

      # not all responses include a meta
      if doc['meta']
        error = doc.fetch('results', {}).fetch('error', {})
        message = error.fetch('type', 'Unknown Error') + ': ' + error.fetch('message', 'No message')
        log_message = 'Pelias Geocoding API error - ' + message
        case doc['meta']['status_code']
          when '200'
            # nothing to see here
          when '403'
            raise_error(Geocoder::RequestDenied, message) || Geocoder.log(:warn, log_message)
          when '429'
            raise_error(Geocoder::OverQueryLimitError, message) || Geocoder.log(:warn, log_message)
          else
            raise_error(Geocoder::Error, message) || Geocoder.log(:warn, log_message)
        end
      end

      doc['features'] || []
    end
  end
end
