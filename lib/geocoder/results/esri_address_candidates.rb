require 'geocoder/results/base'

module Geocoder::Result
  class EsriAddressCandidates < Base

    def address
      attributes['Match_addr']
    end

    def city
      if is_city?
        place_name
      else
        attributes['City']
      end
    end

    def state_code
      attributes['Region']
    end

    alias_method :state, :state_code

    def country
      attributes['Country']
    end

    alias_method :country_code, :country

    def postal_code
      attributes['Postal']
    end

    def place_name
      attributes['PlaceName']
    end

    def place_type
      attributes['Addr_Type']
    end

    def score
      @data['score'].to_f
    end

    def coordinates
      [geometry['y'], geometry['x']]
    end

    def viewport
      north = attributes['Ymax']
      south = attributes['Ymin']
      east = attributes['Xmax']
      west = attributes['Xmin']
      [south, west, north, east]
    end

    private

    def attributes
      @data['extent'].merge(@data['attributes'])
    end

    def geometry
      @data['location']
    end

    def reverse_geocode?
      false
    end

    def is_city?
      ['City', 'State Capital', 'National Capital'].include?(place_type)
    end
  end
end
