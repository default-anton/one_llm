# frozen_string_literal: true

module Onellm
  # Client class for interacting with multiple LLM APIs in a unified interface.
  #
  # The Client handles API requests to various language model providers (OpenAI, Anthropic, etc.)
  # using a standardized OpenAI-compatible format.
  #
  # @example Basic usage
  #   client = Onellm::Client.new(configuration)
  #   response = client.complete(
  #     model: "openai/gpt-4",
  #     messages: [{ role: "user", content: "Hello!" }]
  #   )
  #
  # @note The client requires a valid configuration object that has been properly initialized
  #   with API keys and other necessary settings.
  class Client
    def initialize(configuration)
      @configuration = configuration
      @configuration.validate!
    end

    def complete(model:, messages:, stream: false, &block)
      # Implementation of the complete method
      # Handle different providers based on model prefix
      # Implement streaming support
      # Return response in OpenAI format
      raise NotImplementedError, 'Client#complete not yet implemented'
    end

    private

    attr_reader :configuration
  end
end
