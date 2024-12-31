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

    describe 'function calling' do
      let(:weather_function) do
        {
          type: 'function',
          function: {
            name: 'get_current_weather',
            description: 'Get the current weather in a given location',
            parameters: {
              type: 'object',
              properties: {
                location: {
                  type: 'string',
                  description: 'The city and state, e.g. San Francisco, CA'
                },
                unit: {
                  type: 'string',
                  enum: %w[celsius fahrenheit]
                }
              },
              required: ['location']
            }
          }
        }
      end

      it 'handles function calling with auto tool choice' do
        response = provider.complete(
          model: valid_model,
          messages: [{ role: 'user', content: "What's the weather like in Boston today?" }],
          tools: [weather_function],
          tool_choice: 'auto'
        )

        expect(response).to be_a(Onellm::Response)
        expect(response.choices).to be_an(Array)
        expect(response.choices.first.message.tool_calls).to be_an(Array)
        expect(response.choices.first.message.tool_calls.first.function.name).to eq('get_current_weather')
      end

      it 'handles function calling with specific tool choice' do
        response = provider.complete(
          model: valid_model,
          messages: [{ role: 'user', content: "What's the weather like in Boston today?" }],
          tools: [weather_function],
          tool_choice: { type: 'function', function: { name: 'get_current_weather' } }
        )

        expect(response).to be_a(Onellm::Response)
        expect(response.choices).to be_an(Array)
        expect(response.choices.first.message.tool_calls).to be_an(Array)
        expect(response.choices.first.message.tool_calls.first.function.name).to eq('get_current_weather')
      end

      describe 'validation errors' do
        it 'raises error for invalid tools format' do
          expect do
            provider.complete(
              model: valid_model,
              messages: valid_messages,
              tools: [{ invalid: 'format' }]
            )
          end.to raise_error(ArgumentError, /Tools must be an array of function definitions/)
        end

        it 'raises error for invalid tool choice format' do
          expect do
            provider.complete(
              model: valid_model,
              messages: valid_messages,
              tools: [weather_function],
              tool_choice: 'invalid'
            )
          end.to raise_error(ArgumentError, /Tool choice must be 'auto', 'none', or a function specification/)
        end

        it 'raises error for tool choice without tools' do
          expect do
            provider.complete(
              model: valid_model,
              messages: valid_messages,
              tool_choice: 'auto'
            )
          end.to raise_error(ArgumentError, /Cannot specify tool_choice without tools/)
        end

        it 'raises error for non-existent tool in tool choice' do
          expect do
            provider.complete(
              model: valid_model,
              messages: valid_messages,
              tools: [weather_function],
              tool_choice: { type: 'function', function: { name: 'non_existent_function' } }
            )
          end.to raise_error(ArgumentError, /Tool choice function 'non_existent_function' not found in tools/)
        end
      end
    end

    describe 'validation errors' do
      it 'raises error for empty messages' do
        expect do
          provider.complete(model: valid_model, messages: [])
        end.to raise_error(ArgumentError, /Messages cannot be empty/)
      end

      it 'raises error for invalid message structure' do
        expect do
          provider.complete(model: valid_model, messages: [{ role: 'user' }])
        end.to raise_error(ArgumentError, /Message must be a hash with :role and :content keys only/)
      end

      it 'raises error for invalid role' do
        expect do
          provider.complete(model: valid_model, messages: [{ role: 'invalid', content: 'test' }])
        end.to raise_error(ArgumentError, /Invalid role: invalid. Valid roles are: system, user, assistant/)
      end

      it 'raises error for invalid content type' do
        expect do
          provider.complete(model: valid_model, messages: [{ role: 'user', content: 123 }])
        end.to raise_error(ArgumentError, /Content must be a string or an array of content parts/)
      end

      it 'raises error for invalid content array' do
        expect do
          provider.complete(model: valid_model, messages: [{ role: 'user', content: [{ type: 'invalid' }] }])
        end.to raise_error(ArgumentError, /Invalid content part. Each part must have :type \(text, image_url\)/)
      end

      it 'raises error for missing text part in content array' do
        expect do
          provider.complete(model: valid_model,
                            messages: [{ role: 'user',
                                         content: [{ type: 'image_url',
                                                     image_url: { url: 'https://example.com/image.jpg' } }] }])
        end.to raise_error(ArgumentError, /Content array must contain at least one text part/)
      end

      it 'raises error for invalid image URL' do
        expect do
          provider.complete(model: valid_model,
                            messages: [{ role: 'user',
                                         content: [{ type: 'text', text: 'test' },
                                                   { type: 'image_url', image_url: { url: 'invalid' } }] }])
        end.to raise_error(ArgumentError, %r{Image URL must be a valid HTTP/HTTPS URL or data URI})
      end

      it 'raises error for invalid API key' do
        Onellm.configure do |config|
          allow(config).to receive(:openai_api_key).and_return('invalid-key')
        end

        expect do
          provider.complete(model: valid_model, messages: valid_messages)
        end.to raise_error(Onellm::ConfigurationError, /Invalid OpenAI API key format/)
      end
    end
  end
end
