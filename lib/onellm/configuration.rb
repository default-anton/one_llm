# frozen_string_literal: true

module Onellm
  # Configuration class for managing API keys and settings for Onellm
  #
  # @attr [String] openai_api_key API key for OpenAI services
  # @attr [String] anthropic_api_key API key for Anthropic services
  class Configuration
    # Format patterns for API keys
    OPENAI_KEY_FORMAT = /^sk-[a-zA-Z0-9]{48}$/
    # ANTHROPIC_KEY_FORMAT = /^sk-[a-zA-Z0-9]{40}$/

    attr_accessor :openai_api_key, :anthropic_api_key

    def initialize
      @openai_api_key = ENV.fetch('OPENAI_API_KEY', nil)
      @anthropic_api_key = ENV.fetch('ANTHROPIC_API_KEY', nil)
    end

    # Validates the configuration and raises ConfigurationError if invalid
    #
    # @raise [ConfigurationError] if configuration is invalid
    def validate!
      errors = []

      if openai_api_key.nil? && anthropic_api_key.nil?
        errors << 'At least one API key (OpenAI or Anthropic) must be configured'
      end

      errors << 'Invalid OpenAI API key format' if openai_api_key && !valid_openai_key?(openai_api_key)
      # errors << 'Invalid Anthropic API key format' if anthropic_api_key && !valid_anthropic_key?(anthropic_api_key)

      raise ConfigurationError, errors.join("\n") unless errors.empty?
    end

    private

    # Validates OpenAI API key format
    #
    # @param key [String] The API key to validate
    # @return [Boolean] true if valid, false otherwise
    def valid_openai_key?(key)
      key.match?(OPENAI_KEY_FORMAT)
    end

    # Validates Anthropic API key format
    #
    # @param key [String] The API key to validate
    # @return [Boolean] true if valid, false otherwise
    def valid_anthropic_key?(key)
      key.match?(ANTHROPIC_KEY_FORMAT)
    end
  end
end
