# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module Onellm
  # Provider implementation for OpenAI
  class OpenAIProvider < Provider
    OPENAI_API_URL = 'https://api.openai.com/v1/chat/completions'
    OPEN_TIMEOUT = 10 # seconds
    DEFAULT_TIMEOUT = 30 # seconds
    MAX_RETRIES = 3

    def complete(model:, messages:, stream: false, &block)
      validate_inputs(model, messages)

      uri = URI.parse(OPENAI_API_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      configure_http(http)

      request = Net::HTTP::Post.new(uri)
      configure_request(request)

      payload = build_payload(model, messages, stream)
      request.body = payload.to_json

      if stream
        handle_streaming_response(http, request, &block)
      else
        handle_standard_response(http, request)
      end
    rescue StandardError => e
      handle_error(e)
    end

    private

    def validate_inputs(model, messages)
      raise ArgumentError, 'Model cannot be empty' if model.to_s.strip.empty?
      raise ArgumentError, 'Messages cannot be empty' if messages.empty?

      messages.each do |message|
        raise ArgumentError, 'Each message must have role and content' unless message[:role] && message[:content]
      end
    end

    def configure_http(http)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.open_timeout = OPEN_TIMEOUT
      http.read_timeout = DEFAULT_TIMEOUT
      http.write_timeout = DEFAULT_TIMEOUT
    end

    def configure_request(request)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{config.openai_api_key}"
      request['Accept'] = 'application/json'
    end

    def build_payload(model, messages, stream)
      {
        model: model,
        messages: messages,
        stream: stream
      }
    end

    def handle_standard_response(http, request)
      response = http.request(request)
      handle_http_response(response)
    end

    def handle_streaming_response(http, request, &block)
      request['Accept'] = 'text/event-stream'

      http.request(request) do |response|
        handle_http_response(response)

        response.read_body do |chunk|
          process_stream_chunk(chunk, &block)
        end
      end
    end

    # TODO: better error handling. define error classes
    def handle_http_response(response)
      case response
      when Net::HTTPSuccess
        JSON.parse(response.body, symbolize_names: true)
      when Net::HTTPClientError
        raise APIError, "Client error: #{response.code} - #{response.body}"
      when Net::HTTPServerError
        raise APIError, "Server error: #{response.code} - #{response.body}"
      else
        raise Error, "Unexpected response: #{response.code} - #{response.body}"
      end
    end

    def process_stream_chunk(chunk)
      # Handle SSE format and parse JSON
      chunk.split("\n\n").each do |event|
        next if event.empty?

        data = event.sub(/^data: /, '')
        next if data == '[DONE]'

        parsed = JSON.parse(data, symbolize_names: true)
        yield(parsed)
      end
    rescue JSON::ParserError => e
      raise Error, "Failed to parse streaming chunk: #{e.message}"
    end

    def handle_error(error)
      case error
      when Net::OpenTimeout, Net::ReadTimeout
        raise TimeoutError, "Request timed out: #{error.message}"
      when OpenSSL::SSL::SSLError
        raise SSLError, "SSL verification failed: #{error.message}"
      when SocketError
        raise NetworkError, "Network connection failed: #{error.message}"
      else
        raise Error, "Unexpected error: #{error.message}"
      end
    end
  end
end
