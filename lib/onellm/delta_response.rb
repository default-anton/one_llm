# frozen_string_literal: true

module Onellm
  # Represents a streaming response chunk from an LLM API call
  class DeltaResponse
    attr_reader :id, :created, :model, :object, :system_fingerprint, :choices

    def initialize(attributes = {})
      @id = attributes[:id]
      @created = attributes[:created]
      @model = attributes[:model]
      @object = attributes[:object]
      @system_fingerprint = attributes[:system_fingerprint]
      @choices = attributes[:choices]&.map { |choice| DeltaChoice.new(choice) } || []
    end

    def to_h
      {
        id: id,
        created: created,
        model: model,
        object: object,
        system_fingerprint: system_fingerprint,
        choices: choices.map(&:to_h)
      }
    end
  end

  # Represents a single choice in a streaming response chunk
  class DeltaChoice
    attr_reader :finish_reason, :index, :delta, :logprobs

    def initialize(attributes = {})
      @finish_reason = attributes[:finish_reason]
      @index = attributes[:index]
      @delta = Delta.new(attributes[:delta] || {})
      @logprobs = attributes[:logprobs]
    end

    def to_h
      {
        finish_reason: finish_reason,
        index: index,
        delta: delta.to_h,
        logprobs: logprobs
      }
    end
  end

  # Represents an individual tool call in a streaming chunk
  class DeltaToolCall < ToolCall
    attr_reader :index

    def initialize(attributes = {})
      @index = attributes[:index]
      super
    end

    def to_h
      super.merge(index: index)
    end
  end

  # Represents the delta content in a streaming chunk
  class Delta
    attr_reader :content, :role, :tool_calls

    def initialize(attributes = {})
      @content = attributes[:content]
      @role = attributes[:role]
      @tool_calls = attributes[:tool_calls]&.map { |tc| DeltaToolCall.new(tc) } || []
    end

    def to_h
      {
        content: content,
        role: role,
        tool_calls: tool_calls.map(&:to_h)
      }.compact
    end
  end
end
