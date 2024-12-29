# frozen_string_literal: true

module Onellm
  # Registry for managing LLM providers
  class ProviderRegistry
    def initialize
      @providers = {}
    end

    def register(prefix, provider_class)
      @providers[prefix] = provider_class
    end

    def get_provider(model)
      prefix = model.split('/').first
      provider_class = @providers[prefix]
      raise "Unsupported provider: #{prefix}" unless provider_class

      provider_class
    end
  end
end
