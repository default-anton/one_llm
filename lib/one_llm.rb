# frozen_string_literal: true

require_relative 'one_llm/version'
require_relative 'one_llm/configuration'
require_relative 'one_llm/client'
require_relative 'one_llm/provider'
require_relative 'one_llm/provider_registry'
require_relative 'one_llm/providers/openai_provider'

# Onellm is a Ruby SDK for interacting with multiple LLM APIs in OpenAI format.
#
# It provides a unified interface to call 100+ LLM APIs including Bedrock, Azure,
# OpenAI, VertexAI, Cohere, DeepSeek AI, Sagemaker, HuggingFace, Replicate, and Groq.
#
# @example Basic usage
#   Onellm.configure do |config|
#     config.openai_api_key = "your-openai-key"
#   end
#
#   response = Onellm.complete(
#     model: "openai/gpt-4o",
#     messages: [{ content: "Hello, how are you?", role: "user" }]
#   )
#
# @example Streaming
#   Onellm.complete(
#     model: "openai/gpt-4o",
#     messages: [{ content: "Hello, how are you?", role: "user" }],
#     stream: true
#   ) do |part|
#     puts part.choices.first.delta.content
#   end
#
# @note All API responses follow the OpenAI format for consistency.
module Onellm
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class APIError < Error; end

  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def provider_registry
      @provider_registry ||= ProviderRegistry.new.tap do |registry|
        registry.register('openai', OpenAIProvider)
        # Add more providers here
      end
    end

    def complete(model:, messages:, stream: false, &block)
      client.complete(model: model, messages: messages, stream: stream, &block)
    end

    private

    def client
      @client ||= Client.new(configuration, provider_registry)
    end
  end
end
