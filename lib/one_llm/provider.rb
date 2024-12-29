# frozen_string_literal: true

module Onellm
  # Base class for all LLM providers
  class Provider
    def initialize(config)
      @config = config
    end

    def complete(model:, messages:, stream: false, &block)
      raise NotImplementedError
    end

    private

    attr_reader :config
  end
end
