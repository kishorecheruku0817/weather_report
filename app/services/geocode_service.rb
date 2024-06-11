class GeocodeService
  def self.call(address)
    response = Geocoder.search(address)
    raise IOError.new("Geocoder error") unless response
    raise IOError.new("Geocoder is empty: #{response}") if response.empty?

    data = response.first.data
    raise IOError.new("Geocoder data error") unless data

    validate_geocoder_data(data)

    geocode = map_data_to_geocode(data)
    geocode
  end

  private

  def self.validate_geocoder_data(data)
    raise IOError.new("Geocoder latitude is missing") unless data["lat"]
    raise IOError.new("Geocoder longitude is missing") unless data["lon"]
    raise IOError.new("Geocoder address is missing") unless data["address"]
    raise IOError.new("Geocoder country code is missing") unless data["address"]["country_code"]
    raise IOError.new("Geocoder postal code is missing") unless data["address"]["postcode"]
  end

  def self.map_data_to_geocode(data)
    geocode = OpenStruct.new
    geocode.latitude = data["lat"].to_f
    geocode.longitude = data["lon"].to_f
    geocode.country_code = data["address"]["country_code"]
    geocode.postal_code = data["address"]["postcode"]
    geocode
  end
end
