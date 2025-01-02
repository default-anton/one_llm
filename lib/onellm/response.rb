# frozen_string_literal: true

module Onellm
  # Represents the complete response from an LLM API call
  # TODO: add all usage fields
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
    attr_reader :finish_reason, :index, :message, :logprobs

    def initialize(attributes = {})
      @finish_reason = attributes[:finish_reason]
      @index = attributes[:index]
      @message = Message.new(attributes[:message] || {})
      @logprobs = attributes[:logprobs] ? Logprobs.new(attributes[:logprobs]) : nil
    end

    def to_h
      {
        finish_reason: finish_reason,
        index: index,
        message: message.to_h,
        logprobs: logprobs&.to_h
      }
    end
  end

  # Represents a function call
  class FunctionCall
    attr_reader :name, :arguments

    def initialize(attributes = {})
      @name = attributes[:name]
      @arguments = attributes[:arguments]
    end

    def to_h
      {
        name: name,
        arguments: arguments
      }
    end
  end

  # Represents a tool call
  class ToolCall
    attr_reader :id, :type, :function

    def initialize(attributes = {})
      @id = attributes[:id]
      @type = attributes[:type] || 'function'
      @function = FunctionCall.new(attributes[:function] || {})
    end

    def to_h
      {
        id: id,
        type: type,
        function: function.to_h
      }
    end
  end

  # Represents the message content in a choice
  class Message
    attr_reader :content, :role, :tool_calls, :function_call

    def initialize(attributes = {})
      @content = attributes[:content]
      @role = attributes[:role]
      @tool_calls = attributes[:tool_calls]&.map { |tc| ToolCall.new(tc) } || []
      @function_call = attributes[:function_call] ? FunctionCall.new(attributes[:function_call]) : nil
    end

    def to_h
      {
        content: content,
        role: role,
        tool_calls: tool_calls.map(&:to_h),
        function_call: function_call&.to_h
      }
    end
  end

  # Represents individual token probability information
  class ContentLogprob
    attr_reader :token, :logprob, :bytes, :top_logprobs

    def initialize(attributes = {})
      @token = attributes[:token]
      @logprob = attributes[:logprob]
      @bytes = attributes[:bytes]
      @top_logprobs = attributes[:top_logprobs]&.map { |tl| TopLogprob.new(tl) } || []
    end

    def to_h
      {
        token: token,
        logprob: logprob,
        bytes: bytes,
        top_logprobs: top_logprobs.map(&:to_h)
      }
    end
  end

  # Represents token-level probability information
  class Logprobs
    attr_reader :content

    def initialize(attributes = {})
      @content = attributes[:content]&.map { |cl| ContentLogprob.new(cl) } || []
    end

    def to_h
      {
        content: content.map(&:to_h)
      }
    end
  end

  # Represents top log probability information
  class TopLogprob
    attr_reader :token, :logprob, :bytes

    def initialize(attributes = {})
      @token = attributes[:token]
      @logprob = attributes[:logprob]
      @bytes = attributes[:bytes]
    end

    def to_h
      {
        token: token,
        logprob: logprob,
        bytes: bytes
      }
    end
  end

  # Represents completion tokens details
  class CompletionTokensDetails
    attr_reader :reasoning_tokens, :accepted_prediction_tokens, :rejected_prediction_tokens

    def initialize(attributes = {})
      @reasoning_tokens = attributes[:reasoning_tokens]
      @accepted_prediction_tokens = attributes[:accepted_prediction_tokens]
      @rejected_prediction_tokens = attributes[:rejected_prediction_tokens]
    end

    def to_h
      {
        reasoning_tokens: reasoning_tokens,
        accepted_prediction_tokens: accepted_prediction_tokens,
        rejected_prediction_tokens: rejected_prediction_tokens
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
      @completion_tokens_details = if attributes[:completion_tokens_details]
                                     CompletionTokensDetails.new(attributes[:completion_tokens_details])
                                   end
      @prompt_tokens_details = attributes[:prompt_tokens_details] || {}
      @cache_creation_input_tokens = attributes[:cache_creation_input_tokens]
      @cache_read_input_tokens = attributes[:cache_read_input_tokens]
    end

    def to_h
      {
        completion_tokens: completion_tokens,
        prompt_tokens: prompt_tokens,
        total_tokens: total_tokens,
        completion_tokens_details: completion_tokens_details&.to_h,
        prompt_tokens_details: prompt_tokens_details,
        cache_creation_input_tokens: cache_creation_input_tokens,
        cache_read_input_tokens: cache_read_input_tokens
      }
    end
  end
end
