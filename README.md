# Onellm

Ruby SDK to call 100+ LLM APIs in OpenAI format - [Bedrock, Azure, OpenAI, VertexAI, Cohere, Anthropic, Sagemaker, HuggingFace, Replicate, Groq]

## Usage Examples

### Configuration

```ruby
Onellm.configure do |config|
  config.openai_api_key = "your-openai-key"
  config.anthropic_api_key = "your-cohere-key"
end
```

### Module-based Style
```ruby
response = Onellm.complete(
  model: "openai/gpt-4o-mini",
  messages: [{ content: "Hello, how are you?", role: "user" }]
)

puts response.choices.first.message.content
```

### Class-based Style
```ruby
client = Onellm::Client.new

response = client.complete(
  model: "openai/gpt-4o",
  messages: [{ content: "Hello, how are you?", role: "user" }]
)

puts response.choices.first.message.content
```

### Streaming
```ruby
Onellm.complete(
  model: "openai/gpt-4o",
  messages: [{ content: "Hello, how are you?", role: "user" }],
  stream: true
) do |part|
  puts part.choices.first.delta.content
end
```

### Response (OpenAI Format)
```json
{
    "id": "chatcmpl-565d891b-a42e-4c39-8d14-82a1f5208885",
    "created": 1734366691,
    "model": "claude-3-sonnet-20240229",
    "object": "chat.completion",
    "system_fingerprint": null,
    "choices": [
        {
            "finish_reason": "stop",
            "index": 0,
            "message": {
                "content": "Hello! As an AI language model, I don't have feelings, but I'm operating properly and ready to assist you with any questions or tasks you may have. How can I help you today?",
                "role": "assistant",
                "tool_calls": null,
                "function_call": null
            }
        }
    ],
    "usage": {
        "completion_tokens": 43,
        "prompt_tokens": 13,
        "total_tokens": 56,
        "completion_tokens_details": null,
        "prompt_tokens_details": {
            "audio_tokens": null,
            "cached_tokens": 0
        },
        "cache_creation_input_tokens": 0,
        "cache_read_input_tokens": 0
    }
}
```
## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/default-anton/onellm. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/default-anton/onellm/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Onellm project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/default-anton/onellm/blob/main/CODE_OF_CONDUCT.md).
