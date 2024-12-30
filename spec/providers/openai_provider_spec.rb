# frozen_string_literal: true

require 'spec_helper'
require 'base64'

RSpec.describe Onellm::OpenAIProvider do
  let(:provider) { Onellm::Client.new }
  let(:valid_model) { 'openai/gpt-4o-mini' }
  let(:valid_messages) { [{ role: 'user', content: 'Hello, how are you?' }] }

  before do
    skip 'OPENAI_API_KEY not set' unless ENV['OPENAI_API_KEY']
  end

  describe '#complete' do
    it 'returns a successful response' do
      response = provider.complete(model: valid_model, messages: valid_messages)

      expect(response).to be_a(Onellm::Response)
      expect(response.choices).to be_an(Array)
      expect(response.choices.first.message.content).to be_a(String)
    end

    it 'yields streaming chunks' do
      chunks = []
      provider.complete(model: valid_model, messages: valid_messages, stream: true) do |chunk|
        chunks << chunk
      end

      expect(chunks).to be_an(Array)
      expect(chunks).not_to be_empty
      expect(chunks.first.choices).to be_an(Array)
      expect(chunks.first.choices.first.delta.role).to eq 'assistant'
      expect(chunks.first.choices.first.delta.content).to be_a(String)
    end

    it 'raises error for empty messages' do
      expect do
        provider.complete(model: valid_model, messages: [])
      end.to raise_error(ArgumentError, /Messages cannot be empty/)
    end

    it 'raises error for invalid message format' do
      expect do
        provider.complete(model: valid_model, messages: [{ role: 'user' }])
      end.to raise_error(ArgumentError, /Each message must have role and content/)
    end

    it 'raises error for invalid API key' do
      Onellm.configure do |config|
        config.openai_api_key = 'invalid-key'
      end

      expect do
        provider.complete(model: valid_model, messages: valid_messages)
      end.to raise_error(Onellm::ConfigurationError, /Invalid OpenAI API key format/)
    end

    it 'handles image content in messages' do
      image_url = 'https://raw.githubusercontent.com/default-anton/onellm/refs/heads/main/spec/data/Delta_Air_Lines_B767-332_N130DL%20Small.jpeg'
      messages = [
        {
          role: 'user',
          content: [
            {
              type: 'text',
              text: "What's in this image?"
            },
            {
              type: 'image_url',
              image_url: {
                url: image_url
              }
            }
          ]
        }
      ]

      response = provider.complete(model: valid_model, messages: messages)

      expect(response).to be_a(Onellm::Response)
      expect(response.choices).to be_an(Array)
      expect(response.choices.first.message.content).to be_a(String)
    end

    it 'handles Base64 encoded local image content in messages' do
      # Read and encode the local image file
      image_path = Pathname(__dir__).parent.join('data', 'Delta_Air_Lines_B767-332_N130DL Small.jpeg')
      base64_image = Base64.strict_encode64(image_path.read(mode: 'rb'))

      messages = [
        {
          role: 'user',
          content: [
            {
              type: 'text',
              text: "What's in this image?"
            },
            {
              type: 'image_url',
              image_url: {
                url: "data:image/jpeg;base64,#{base64_image}"
              }
            }
          ]
        }
      ]

      response = provider.complete(model: valid_model, messages: messages)

      expect(response).to be_a(Onellm::Response)
      expect(response.choices).to be_an(Array)
      expect(response.choices.first.message.content).to be_a(String)
    end
  end
end
