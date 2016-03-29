require 'geocoder/results/base'

module Geocoder::Result
  class EsriAddressCandidates < Base

    def address
      address_key = reverse_geocode? ? 'Address' : 'Match_addr'
      attributes[address_key]
    end

    def city
      if !reverse_geocode? && is_city?
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
      country_key = reverse_geocode? ? 'CountryCode' : 'Country'
      attributes[country_key]
    end

    alias_method :country_code, :country

    def postal_code
      attributes['Postal']
    end

    def place_name
      place_name_key = reverse_geocode? ? 'Address' : 'PlaceName'
      attributes[place_name_key]
    end

    def place_type
      reverse_geocode? ? 'Address' : attributes['Addr_Type']
    end

    def score
      reverse_geocode? ? nil : @data['score']
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
      reverse_geocode? ? @data['address'] : @data['extent'].merge(@data['attributes'])
    end

    def geometry
      reverse_geocode? ? @data['location'] : @data['location']
    end

    def reverse_geocode?
      @data['candidates'].nil?
    end

    def is_city?
      ['City', 'State Capital', 'National Capital'].include?(place_type)
    end
  end
end

