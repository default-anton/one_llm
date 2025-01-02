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
