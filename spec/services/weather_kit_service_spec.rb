require 'rails_helper'

describe WeatherKitService do
  let!(:lat) { '25.2323' }
  let!(:lon) { '-75.24323' }
  let!(:secret) { '12345' }
  let!(:url) { "https://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=#{lon}&appid=#{secret}&units=imperial" }

  subject { described_class.new(lat, lon) }

  before do
    stub_const("#{described_class}::API_SECRET", secret)
  end

  describe '#initialize' do
    context 'initialized options are found' do
      it 'raises no error' do
        expect { subject }.not_to raise_error
      end

      it 'sets the latitude' do
        expect(subject.lat).to eq(lat)
      end

      it 'sets the longitude' do
        expect(subject.lon).to eq(lon)
      end
    end
  end

  describe '#perform' do
    let!(:success_response) { Net::HTTPSuccess.new(1.0, '200', 'OK') }
    let!(:unauth_error_response) { Net::HTTPUnauthorized.new(1.0, '500', 'OK') }
    let!(:not_found_error_response) { Net::HTTPNotFound.new(1.0, '500', 'OK') }
    let!(:other_error) { Net::HTTPBadRequest.new(1.0, '500', 'OK') }
    let!(:data) { file_fixture("weather_data.json").read }
    let!(:expires_at) { Time.now + 30.minutes }
    let!(:data_with_expires_at) { JSON.parse(data).merge("expires_at" => expires_at) }

    it 'calls OpenWetherAPI with correct arguments with zipcode' do
      # This prevents the elusive "undefined method `close' for nil:NilClass" error.
      expect(success_response).to receive(:body).once { data }

      # Stub API request in test and return mock error response.
      expect(Net::HTTP).to receive(:get_response).once.with(URI(url)).and_return(success_response)

      subject.perform
    end

    it 'sets the correct data' do
      # Stub time to expiration to prevent timestamp causing a mismatch.
      allow(subject).to receive(:time_to_expiration).once { expires_at }

      # This prevents the elusive "undefined method `close' for nil:NilClass" error.
      allow(success_response).to receive(:body).once { data }      

      # Stub API request in test and return mock success response.
      allow(Net::HTTP).to receive(:get_response).once.with(URI(url)).and_return(success_response)

      subject.perform

      expect(subject.data).to eq(data_with_expires_at)
    end

    context 'response contains errors' do
      it 'raises OpenWeatherError if HTTPUnauthorized response' do
        # Stub API request in test and return mock error response.
        allow(Net::HTTP).to receive(:get_response).once.with(URI(url)).and_return(unauth_error_response)

        expect { subject.perform }.to raise_error(OpenWeatherError, 'Invalid API Key')
      end

      it 'raises OpenWeatherError if HTTPNotFound response' do
        # Stub API request in test and return mock error response.
        allow(Net::HTTP).to receive(:get_response).once.with(URI(url)).and_return(not_found_error_response)

        expect { subject.perform }.to raise_error(OpenWeatherError, 'Not Found')
      end

      it 'raises OpenWeatherError if other response' do
        # Stub API request in test and return mock error response.
        allow(Net::HTTP).to receive(:get_response).once.with(URI(url)).and_return(other_error)

        # This prevents the elusive "undefined method `close' for nil:NilClass" error.
        allow(other_error).to receive(:body).once { {'message': 'Error Message'}.to_json }      

        expect { subject.perform }.to raise_error(OpenWeatherError, 'Error Message')
      end
    end
  end
end
