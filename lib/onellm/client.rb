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
    def initialize(configuration = Onellm.configuration, provider_registry = Onellm.provider_registry)
      @configuration = configuration
      @provider_registry = provider_registry
      @configuration.validate!
    end

    def complete(model:, messages:, stream: false, tools: nil, tool_choice: nil,
                 reasoning_effort: 'medium', metadata: nil, frequency_penalty: 0,
                 logit_bias: nil, logprobs: false, top_logprobs: nil,
                 max_tokens: nil, max_completion_tokens: nil, presence_penalty: 0,
                 top_p: 1, temperature: 1, stop: nil)
      provider_class = @provider_registry.get_provider(model)
      provider = provider_class.new(@configuration)
      response = provider.complete(
        model: model.split('/').last,
        messages: messages,
        stream: stream,
        tools: tools,
        tool_choice: tool_choice,
        reasoning_effort: reasoning_effort,
        metadata: metadata,
        frequency_penalty: frequency_penalty,
        logit_bias: logit_bias,
        logprobs: logprobs,
        top_logprobs: top_logprobs,
        max_tokens: max_tokens,
        max_completion_tokens: max_completion_tokens,
        presence_penalty: presence_penalty,
        top_p: top_p,
        temperature: temperature,
        stop: stop
      ) do |chunk|
        yield DeltaResponse.new(chunk)
      end

      Response.new(response)
    end

    private

    attr_reader :configuration, :provider_registry
  end
end
