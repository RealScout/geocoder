# encoding: utf-8
require 'test_helper'

class PeliasTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :pelias, api_key: 'abc123')
  end

  # def test_configure_custom_endpoint
  #   Geocoder.configure(lookup: :pelias, api_key: 'abc123', pelias: {endpoint: 'self.hosted.pelias/proxy'})
  #   query = Geocoder::Query.new('Madison Square Garden, New York, NY')
  #   assert_true query.url.start_with?('http://self.hosted.pelias/proxy/v1/search'), query.url
  # end

  def test_configure_default_endpoint
    query = Geocoder::Query.new('Madison Square Garden, New York, NY')
    assert_true query.url.start_with?('http://localhost/v1/search'), query.url
  end

  # def test_raises_exception_when_service_unavailable
  #   Geocoder.configure(:always_raise => [Geocoder::ServiceUnavailable])
  #   l = Geocoder::Lookup.get(:pelias)
  #   assert_raises Geocoder::ServiceUnavailable do
  #     l.send(:results, Geocoder::Query.new("service unavailable"))
  #   end
  # end
end
