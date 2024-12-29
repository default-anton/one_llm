Ruby SDK to call 100+ LLM APIs in OpenAI format - [Bedrock, Azure, OpenAI, VertexAI, Cohere, Anthropic, Sagemaker, HuggingFace, Replicate, Groq]

### Usage Examples

#### Configuration

```ruby
Onellm.configure do |config|
  config.openai_api_key = "your-openai-key"
  config.anthropic_api_key = "your-cohere-key"
end
```

#### Module-based Style
```ruby
response = Onellm.complete(
  model: "openai/gpt-4o",
  messages: [{ content: "Hello, how are you?", role: "user" }]
)

puts response.choices.first.message.content
```

#### Class-based Style
```ruby
client = Onellm::Client.new

response = client.complete(
  model: "openai/gpt-4o",
  messages: [{ content: "Hello, how are you?", role: "user" }]
)

puts response.choices.first.message.content
```

#### Streaming
```ruby
Onellm.complete(
  model: "openai/gpt-4o",
  messages: [{ content: "Hello, how are you?", role: "user" }],
  stream: true
) do |part|
  puts part.choices.first.delta.content
end
```

## Response (OpenAI Format)
```json
{
    "id": "chatcmpl-565d891b-a42e-4c39-8d14-82a1f5208885",
    "created": 1734366691,
    "model": "claude-3-sonnet-20240229",
    "object": "chat.completion",
    "system_fingerprint": nil,
    "choices": [
        {
            "finish_reason": "stop",
            "index": 0,
            "message": {
                "content": "Hello! As an AI language model, I don't have feelings, but I'm operating properly and ready to assist you with any questions or tasks you may have. How can I help you today?",
                "role": "assistant",
                "tool_calls": nil,
                "function_call": nil
            }
        }
    ],
    "usage": {
        "completion_tokens": 43,
        "prompt_tokens": 13,
        "total_tokens": 56,
        "completion_tokens_details": nil,
        "prompt_tokens_details": {
            "audio_tokens": nil,
            "cached_tokens": 0
        },
        "cache_creation_input_tokens": 0,
        "cache_read_input_tokens": 0
    }
}
```
