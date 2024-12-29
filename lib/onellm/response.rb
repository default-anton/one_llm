# frozen_string_literal: true

module Onellm
  # Represents the complete response from an LLM API call
  class Response
    attr_reader :id, :created, :model, :object, :system_fingerprint, :choices, :usage

    def initialize(attributes = {})
      @id = attributes[:id]
      @created = attributes[:created]
      @model = attributes[:model]
      @object = attributes[:object]
      @system_fingerprint = attributes[:system_fingerprint]
      @choices = attributes[:choices]&.map { |choice| Choice.new(choice) } || []
      @usage = Usage.new(attributes[:usage] || {})
    end

    def to_h
      {
        id: id,
        created: created,
        model: model,
        object: object,
        system_fingerprint: system_fingerprint,
        choices: choices.map(&:to_h),
        usage: usage.to_h
      }
    end
  end

  # Represents a single choice in the response
  class Choice
    attr_reader :finish_reason, :index, :message

    def initialize(attributes = {})
      @finish_reason = attributes[:finish_reason]
      @index = attributes[:index]
      @message = Message.new(attributes[:message] || {})
    end

    def to_h
      {
        finish_reason: finish_reason,
        index: index,
        message: message.to_h
      }
    end
  end

  # Represents the message content in a choice
  class Message
    attr_reader :content, :role, :tool_calls, :function_call

    def initialize(attributes = {})
      @content = attributes[:content]
      @role = attributes[:role]
      @tool_calls = attributes[:tool_calls]
      @function_call = attributes[:function_call]
    end

    def to_h
      {
        content: content,
        role: role,
        tool_calls: tool_calls,
        function_call: function_call
      }
    end
  end

  # Represents the token usage information
  class Usage
    attr_reader :completion_tokens, :prompt_tokens, :total_tokens,
                :completion_tokens_details, :prompt_tokens_details,
                :cache_creation_input_tokens, :cache_read_input_tokens

    def initialize(attributes = {})
      @completion_tokens = attributes[:completion_tokens]
      @prompt_tokens = attributes[:prompt_tokens]
      @total_tokens = attributes[:total_tokens]
      @completion_tokens_details = attributes[:completion_tokens_details]
      @prompt_tokens_details = attributes[:prompt_tokens_details] || {}
      @cache_creation_input_tokens = attributes[:cache_creation_input_tokens]
      @cache_read_input_tokens = attributes[:cache_read_input_tokens]
    end

    def to_h
      {
        completion_tokens: completion_tokens,
        prompt_tokens: prompt_tokens,
        total_tokens: total_tokens,
        completion_tokens_details: completion_tokens_details,
        prompt_tokens_details: prompt_tokens_details,
        cache_creation_input_tokens: cache_creation_input_tokens,
        cache_read_input_tokens: cache_read_input_tokens
      }
    end
  end
end
