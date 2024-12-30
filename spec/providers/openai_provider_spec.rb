# frozen_string_literal: true

require 'spec_helper'

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
  end
end
