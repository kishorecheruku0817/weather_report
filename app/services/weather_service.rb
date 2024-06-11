class WeatherService
  BASE_URL = "https://api.openweathermap.org"

  def self.call(latitude, longitude)
    response = connection.get('/data/2.5/weather', {
      appid: Rails.application.credentials.openweather_api_key,
      lat: latitude,
      lon: longitude,
      units: "metric",
    })
    
    body = response.body
    validate_response(body)

    map_data_to_weather(body)
  end

  private

  def self.connection
    Faraday.new(BASE_URL) do |f|
      f.request :json        # Encode request bodies as JSON and automatically set the Content-Type header
      f.request :retry       # Retry transient failures
      f.response :json       # Decode response bodies as JSON
    end
  end

  def self.validate_response(body)
    raise IOError.new("OpenWeather response body failed") unless body
    raise IOError.new("OpenWeather main section is missing") unless body["main"]
    raise IOError.new("OpenWeather temperature is missing") unless body["main"]["temp"]
    raise IOError.new("OpenWeather temperature minimum is missing") unless body["main"]["temp_min"]
    raise IOError.new("OpenWeather temperature maximum is missing") unless body["main"]["temp_max"]
    raise IOError.new("OpenWeather weather section is missing") unless body["weather"]
    raise IOError.new("OpenWeather weather section is empty") if body["weather"].empty?
    raise IOError.new("OpenWeather weather description is missing") unless body["weather"][0]["description"]
  end

  def self.map_data_to_weather(data)
    OpenStruct.new(
      temperature: data["main"]["temp"],
      temperature_min: data["main"]["temp_min"],
      temperature_max: data["main"]["temp_max"],
      humidity: data["main"]["humidity"],
      pressure: data["main"]["pressure"],
      description: data["weather"][0]["description"]
    )
  end
end
