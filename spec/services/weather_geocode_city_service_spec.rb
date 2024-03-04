require 'rails_helper'

describe WeatherGeocodeCityService do
  let!(:query) { 'Houston' }
  let!(:secret) { '12345' }
  let!(:lat) { '25.2323' }
  let!(:lon) { '-75.24323' }
  let!(:city_url) { "http://api.openweathermap.org/geo/1.0/direct?q=#{query}&limit=1&appid=#{secret}" }
 
  subject { described_class.new( query: query ) }

  before do
    stub_const("#{described_class}::API_SECRET", secret)
  end

  describe '#initialize' do
    context 'initialized options are found' do
      it 'raises no error' do
        expect { subject }.not_to raise_error
      end

      it 'sets the query' do
        expect(subject.query).to eq(query)
      end
    end
  end

  describe '#perform' do
    let!(:success_response) { Net::HTTPSuccess.new(1.0, '200', 'OK') }
    let!(:error_response) { Net::HTTPUnauthorized.new(1.0, '500', 'OK') }
    let!(:data) { { "lat" => lat, "lon" => lon } }

    it 'calls OpenWetherAPI with correct arguments with zipcode' do
      # This prevents the elusive "undefined method `close' for nil:NilClass" error.
      expect(success_response).to receive(:body).once { { lat: lat, lon: lon }.to_json }      

      expect(Net::HTTP).to receive(:get_response).once.with(URI(city_url)).and_return(success_response)

      subject.perform
    end

    it 'sets the correct data' do
      allow(success_response).to receive(:body).once { { lat: lat, lon: lon }.to_json }      

      allow(Net::HTTP).to receive(:get_response).once.with(URI(city_url)).and_return(success_response)

      subject.perform

      expect(subject.data).to eq(data)
    end

    it 'raises OpenWeatherError if HTTPUnauthorized response' do
      allow(Net::HTTP).to receive(:get_response).once.with(URI(city_url)).and_return(error_response)

      expect{ subject.perform }.to raise_error(OpenWeatherError, 'Invalid API Key')
    end
  end
end
