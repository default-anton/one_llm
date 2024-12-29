# frozen_string_literal: true

module Onellm
  # Provider implementation for OpenAI
  class OpenAIProvider < Provider
    def complete(model:, messages:, stream: false, &block)
      # Implementation specific to OpenAI API
      # Handle streaming if needed
      # Return response in OpenAI format
      raise NotImplementedError, 'OpenAIProvider#complete not yet implemented'
    end
  end
end
