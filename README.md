# ZohoSign

Zoho Sign exposes the [Zoho Sign API](https://www.zoho.com/sign/api) endpoints through service objects.

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

Each service object returned will undergo validation before the `call` method is invoked to access API endpoints.

```ruby
service.valid? # => true
service.errors # => #<ActiveModel::Errors []>

service.valid? # => false
service.errors # => <ActiveModel::Errors [#<ActiveModel::Error attribute=name, type=blank, options={}>]>
service.errors.full_messages # => ["Name can't be blank"]
```

After a **successful** `call` invocation, the `response` attribute will contain a `Faraday::Response` object.

```ruby
service.response # => #<Faraday::Response ...>
service.response.status # => 200
service.response.body # => {}
```

At this point you will also have a `facade` object which will hold all the attributes for the specific resource.

```ruby
service.facade # => #<ZohoSign::Document::Facade @request_status="inprogress" ...>
service.facade.request_status # => 'inprogress'
```

For convenience, facade attributes can be accessed directly on the service object.

```ruby
service.request_status # => 'inprogress'
```

After a **failed** `call` invocation, a `ZohoSign::RequestError` will be raised with a `response` attribute which will contain a `Faraday::Response` object.

```ruby
rescue ZohoSign::RequestError => exception
  exception.message # => ''
  exception.response # => #<Faraday::Response ...>
  exception.response.status # => 400
  exception.response.body # => {}
```

### Configuration

Configure your API credentials.

In a Rails application, the standard practice is to place this code in a file named `zoho_sign.rb` within the `config/initializers` directory.

```ruby
ZohoSign::BaseService.configure do |config|
  config.client_id = ''
  config.client_secret = ''
  config.refresh_token = ''

  # Optional configuration.
  config.cache = Rails.cache # Default: ActiveSupport::Cache::MemoryStore.new
  config.logger = Rails.logger # Default: Logger.new($stdout)
  config.logger_level = :debug # Default: :info
  config.log_headers = true # Default: false
  config.log_bodies = true # Default: false
end
```

### Documents

#### List documents.

Note that the `offset` starts at `1` for the first item.

If you don't provide a `limit`, multiple API requests will be made untill all records have been returned. You could be
rate limited, so use wisely.

```ruby
ZohoSign::Document::ListService.call(offset: 1, limit: 10).each do |service|
  service.description
end
```

Sort by column.

```ruby
  ZohoSign::Document::ListService.call(sort_column: 'recipient_email', sort_order: 'ASC').map { _1 }
```

Filter by column.

```ruby
  ZohoSign::Document::ListService.call(search_columns: { recipient_email: 'eric.cartman@example.com' }).map { _1 }
```

Columns to sort and filter by are `request_name`, `folder_name`, `owner_full_name`, `recipient_email`,
`form_name` `created_time`.

#### Get a document.

```ruby
service = ZohoSign::Document::GetService.call(id: '')
service.request_name
service.request_status
service.owner_email
service.owner_first_name
service.owner_last_name
service.attachments
service.sign_percentage
...
```

#### Create a document.

```ruby
service = ZohoSign::Document::CreateService.call(
  request_name: 'Name',
  is_sequential: false,
  actions: [{
    action_type: 'SIGN',
    recipient_email: 'eric.cartman@example.com',
    recipient_name: 'Eric Cartman',
    verify_recipient: true,
    verification_type: 'EMAIL'
  }]
)
```

#### Update a document.

```ruby
service = ZohoSign::Document::UpdateService.call(
  id: '',
  request_name: 'Name',
  is_sequential: false,
  actions: [{
    action_type: 'SIGN',
    recipient_email: 'stan.marsh@example.com',
    recipient_name: 'Stan Marsh',
    verify_recipient: true,
    verification_type: 'EMAIL'
  }]
)
```

#### Delete a document.

```ruby
service = ZohoSign::Document::DeleteService.call(id: '')
```

### Folders
### Field Types
### Request Types
### Templates


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kobusjoubert/zoho_sign.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
