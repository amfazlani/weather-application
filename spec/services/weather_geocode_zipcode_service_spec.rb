require 'rails_helper'

describe WeatherGeocodeZipcodeService do
  let!(:query) { '77471' }
  let!(:secret) { '12345' }
  let!(:lat) { '25.2323' }
  let!(:lon) { '-75.24323' }
  let!(:zip_url) { "http://api.openweathermap.org/geo/1.0/zip?zip=#{query}&limit=1&appid=#{secret}" }
 
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
    let!(:unauth_error_response) { Net::HTTPUnauthorized.new(1.0, '500', 'OK') }
    let!(:not_found_error_response) { Net::HTTPNotFound.new(1.0, '500', 'OK') }
    let!(:other_error) { Net::HTTPBadRequest.new(1.0, '500', 'OK') }
    let!(:data) { { "lat" => lat, "lon" => lon } }

     it 'calls OpenWetherAPI with correct arguments with zipcode' do
      # This prevents the elusive "undefined method `close' for nil:NilClass" error.
      expect(success_response).to receive(:body).once { { lat: lat, lon: lon }.to_json }

      # Stub API request in test and return mock response.
      expect(Net::HTTP).to receive(:get_response).once.with(URI(zip_url)).and_return(success_response)

      subject.perform
    end

    it 'sets the correct data' do
      # This prevents the elusive "undefined method `close' for nil:NilClass" error.
      allow(success_response).to receive(:body).once { { lat: lat, lon: lon }.to_json }      

      # Stub API request in test and return mock response.
      allow(Net::HTTP).to receive(:get_response).once.with(URI(zip_url)).and_return(success_response)

      subject.perform

      expect(subject.data).to eq(data)
    end

    context 'when response contains error' do
      it 'raises OpenWeatherError if HTTPUnauthorized response' do
        # Stub API request in test and return mock error response.
        allow(Net::HTTP).to receive(:get_response).once.with(URI(zip_url)).and_return(unauth_error_response)

        expect { subject.perform }.to raise_error(OpenWeatherError, 'Invalid API Key')
      end

      it 'raises OpenWeatherError if HTTPNotFound response' do
        # Stub API request in test and return mock error response.
        allow(Net::HTTP).to receive(:get_response).once.with(URI(zip_url)).and_return(not_found_error_response)

        expect { subject.perform }.to raise_error(OpenWeatherError, 'Not Found')
      end

      it 'raises OpenWeatherError if other response' do
        # Stub API request in test and return mock error response.
        allow(Net::HTTP).to receive(:get_response).once.with(URI(zip_url)).and_return(other_error)

        # This prevents the elusive "undefined method `close' for nil:NilClass" error.
        allow(other_error).to receive(:body).once { {'message': 'Error Message'}.to_json }      

        expect { subject.perform }.to raise_error(OpenWeatherError, 'Error Message')
      end
    end
  end
end
