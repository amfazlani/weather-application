require 'rails_helper'

RSpec.describe 'Weather', type: :request do
  let(:lat) { '25.2323' }
  let(:lon) { '-75.24323' }
  let(:weather_data) { file_fixture("weather_data.json").read }

  describe '#index' do
    context 'zip as param' do
      let(:zip_query) { '77471' }
      let(:geocode_zip_data) { [{ "name" => zip_query, "lat" => lat, "lon" => lon }] }
      let(:double) { instance_double('WeatherGeocodeZipcodeService') }

      before do
        allow(WeatherGeocodeZipcodeService).to receive(:new).and_return(double)
        expect(double).to receive(:perform).and_return(geocode_zip_data)
        expect(double).to receive(:data).and_return(geocode_zip_data)
      end

      it 'should return correct data' do
        get weather_path, params: { zip: zip_query }, as: :json

        expect(JSON.parse(response.body)).to eq(geocode_zip_data)
      end
    end

    context 'city as param' do
      let(:city_query) { 'Houston' }
      let(:geocode_city_data) { [{ "name" => city_query, "lat" => lat, "lon" => lon }] }
      let(:double) { instance_double('WeatherGeocodeCityService') }

      before do
        allow(WeatherGeocodeCityService).to receive(:new).and_return(double)

        expect(double).to receive(:perform).and_return(geocode_city_data)
        expect(double).to receive(:data).and_return(geocode_city_data)
      end

      it 'should return correct data' do
        get weather_path, params: { city: city_query }, as: :json

        expect(JSON.parse(response.body)).to eq(geocode_city_data)
      end
    end
  end

  describe '#get_weather_data' do
    let(:params) { { lat: lat, lon: lon } }
    let(:weather_response_data) { JSON.parse(weather_data) }
    let(:icon) { '04n' }
    let(:icon_url) { "http://openweathermap.org/img/w/#{icon}.png" }
    let(:double) { instance_double('WeatherKitService') }

    before do
      allow(WeatherKitService).to receive(:new).and_return(double)

      expect(double).to receive(:perform).and_return(weather_response_data)
      expect(double).to receive(:data).and_return(weather_response_data)
      expect(double).to receive(:icon_url).and_return(icon_url)
    end

    it 'should return correct data' do
      get weather_data_path, params: params, as: :json

      expect(JSON.parse(response.body)['data']).to eq(weather_response_data)
    end

    it 'should return correct icon url' do
      get weather_data_path, params: params, as: :json

      expect(JSON.parse(response.body)['icon']).to eq(icon_url)
    end
  end
end
