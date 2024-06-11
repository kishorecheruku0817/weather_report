class WeatherController < ApplicationController
  def show
    @address_default = "1 Infinite Loop, Cupertino, California"
    session[:address] = params[:address] || @address_default
    @address = session[:address]
  
    if @address
      begin
        @geocode = GeocodeService.call(@address)
        @weather_cache_key = "#{@geocode.country_code}/#{@geocode.postal_code}"
        @weather_cache_exist = Rails.cache.exist?(@weather_cache_key)
        @weather = Rails.cache.fetch(@weather_cache_key, expires_in: 30.minutes) do
          WeatherService.call(@geocode.latitude, @geocode.longitude)
        end
      rescue => e
        Rails.logger.error("Error fetching geocode or weather data: #{e.message}")
        flash.alert = "There was an error fetching the geocode or weather data. Please try again later."
        @weather = nil
        @geocode = nil
      end
    end
  end
end
