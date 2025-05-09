# Active Call - Zoho Sign

[![Gem Version](https://badge.fury.io/rb/active_call-zoho_sign.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/active_call-zoho_sign)

Zoho Sign exposes the [Zoho Sign API](https://www.zoho.com/sign/api) endpoints through [Active Call](https://rubygems.org/gems/active_call) service objects.

<div align="center">
  <a href="https://platform45.com?utm_source=github&utm_content=zoho_sign">
    <picture>
      <img src="https://github.com/user-attachments/assets/19fd40df-2ce9-4f30-8120-d53f3fbf9f07">
    </picture>
  </a>
</div>

- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Using call](#using-call)
  - [Using call!](#using-call!)
  - [When to use call or call!](#using-call-or-call!)
  - [Using lists](#using-lists)
- [Service Objects](#service-objects)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add active_call-zoho_sign
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install active_call-zoho_sign
```

## Configuration

Create a new **Self Client** client type from the [Zoho Developer Console](https://api-console.zoho.com) to retrieve your **Client ID** and **Client Secret**.

Choose what you need from the list of [Zoho Scopes](https://www.zoho.com/sign/api/oauth.html) like `ZohoSign.documents.ALL` to generate your **Grant Token**.

Get your **Refresh Token** by calling `ZohoSign::GrantToken::GetService.call(grant_token: '', client_id: '', client_secret: '').refresh_token`

Configure your API credentials.

In a Rails application, the standard practice is to place this code in a file named `zoho_sign.rb` within the `config/initializers` directory.

```ruby
require 'active_call-zoho_sign'

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

While testing, you can set your temporary development OAuth access token in the `ZOHO_SIGN_ACCESS_TOKEN` environment variable. In your production environment,`config.refresh_token` will be used.

## Usage

### <a name='using-call'></a>Using `call`

Each service object returned will undergo validation before the `call` method is invoked to access API endpoints.

After **successful** validation.

```ruby
service.success? # => true
service.errors # => #<ActiveModel::Errors []>
```

After **failed** validation.

```ruby
service.success? # => false
service.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=name, type=blank, options={}>]>
service.errors.full_messages # => ["Name can't be blank"]
```

After a **successful** `call` invocation, the `response` attribute will contain a `Faraday::Response` object.

```ruby
service.success? # => true
service.response # => #<Faraday::Response ...>
service.response.success? # => true
service.response.status # => 200
service.response.body # => {"code"=>0, "message"=>"Document has been retrieved", "status"=>"success", "requests"=>{...}}
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

After a **failed** `call` invocation, the `response` attribute will still contain a `Faraday::Response` object.

```ruby
service.success? # => false
service.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=base, type=Not found, options={}>]>
service.errors.full_messages # => ["No match found"]
service.response # => #<Faraday::Response ...>
service.response.success? # => false
service.response.status # => 400
service.response.body # => {"code"=>9004, "message"=>"No match found", "status"=>"failure"}
```

### <a name='using-call!'></a>Using `call!`

Each service object returned will undergo validation before the `call!` method is invoked to access API endpoints.

After **successful** validation.

```ruby
service.success? # => true
```

After **failed** validation, a `ZohoSign::ValidationError` exception will be raised with an `errors` attribute which 
will contain an `ActiveModel::Errors` object.

```ruby
rescue ZohoSign::ValidationError => exception
  exception.message # => ''
  exception.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=name, type=blank, options={}>]>
  exception.errors.full_messages # => ["Name can't be blank"]
```

After a **successful** `call!` invocation, the `response` attribute will contain a `Faraday::Response` object.

```ruby
service.success? # => true
service.response # => #<Faraday::Response ...>
service.response.success? # => true
service.response.status # => 200
service.response.body # => {"code"=>0, "message"=>"Document has been retrieved", "status"=>"success", "requests"=>{...}}
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

After a **failed** `call!` invocation, a `ZohoSign::RequestError` will be raised with a `response` attribute which will contain a `Faraday::Response` object.

```ruby
rescue ZohoSign::RequestError => exception
  exception.message # => ''
  exception.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=base, type=Not found, options={}>]>
  exception.errors.full_messages # => ["No match found"]
  exception.response # => #<Faraday::Response ...>
  exception.response.status # => 400
  exception.response.body # => {"code"=>9004, "message"=>"No match found", "status"=>"failure"}
```

### <a name='using-call-or-call!'></a>When to use `call` or `call!`

An example of where to use `call` would be in a **controller** doing an inline synchronous request.

```ruby
class SomeController < ApplicationController
  def update
    @document = ZohoSign::Document::UpdateService.call(**params)

    if @document.success?
      redirect_to [@document], notice: 'Success', status: :see_other
    else
      flash.now[:alert] = @document.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end
end
```

An example of where to use `call!` would be in a **job** doing an asynchronous request.

You can use the exceptions to determine which retry strategy to use and which to discard.

```ruby
class SomeJob < ApplicationJob
  discard_on ZohoSign::NotFoundError

  retry_on ZohoSign::RequestTimeoutError, wait: 5.minutes, attempts: :unlimited
  retry_on ZohoSign::TooManyRequestsError, wait: :polynomially_longer, attempts: 10

  def perform
    ZohoSign::Document::UpdateService.call!(**params)
  end
end
```

### Using lists

If you don't provide the `limit` argument, multiple API requests will be made untill all records have been returned. You could be rate limited, so use wisely.

Note that the `offset` argument starts at `1` for the first item.

## Service Objects

<details open>
<summary>Documents</summary>

### Documents

#### List documents

```ruby
# https://www.zoho.com/sign/api/document-managment/get-document-list.html

ZohoSign::Document::ListService.call(offset: 1, limit: 10).each do |facade|
  facade.description
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

Columns to sort and filter by are `request_name`, `folder_name`, `owner_full_name`, `recipient_email`, `form_name` and `created_time`.

#### Get a document

```ruby
# https://www.zoho.com/sign/api/document-managment/get-details-of-a-particular-document.html

service = ZohoSign::Document::GetService.call(id: '')
service.request_name
service.request_id
service.request_status
service.owner_email
service.owner_first_name
service.owner_last_name
service.attachments
service.sign_percentage
...
```

#### Create a document

```ruby
# https://www.zoho.com/sign/api/document-managment/create-document.html

ZohoSign::Document::CreateService.call(
  file: '/path/to/file.pdf', # or File.open('/path/to/file.pdf')
  file_name: 'file.pdf',
  file_content_type: 'application/pdf',
  data: {
    requests: {
      request_name: 'Name',
      is_sequential: false,
      actions: [{
        action_type: 'SIGN',
        recipient_email: 'eric.cartman@example.com',
        recipient_name: 'Eric Cartman',
        verify_recipient: true,
        verification_type: 'EMAIL'
      }]
    }
  }
)
```

#### Update a document

```ruby
# https://www.zoho.com/sign/api/document-managment/update-document.html

ZohoSign::Document::UpdateService.call(
  id: '',
  data: {
    requests: {
      request_name: 'Name Updated',
      actions: [{
        action_id: '',
        action_type: 'SIGN',
        recipient_email: 'stan.marsh@example.com',
        recipient_name: 'Stan Marsh'
      }]
    }
  }
)
```

#### Delete a document

```ruby
# https://www.zoho.com/sign/api/document-managment/delete-document.html

ZohoSign::Document::DeleteService.call(id: '')
```

#### Sign a document

A unique signing URL will be generated, which will be valid for two minutes. If the signing page is not open by then, a new link needs to be generated and it is a one-time usable URL.

```ruby
# https://www.zoho.com/sign/api/embedded-signing.html

service = ZohoSign::Document::Action::EmbedToken::GetService.call(request_id: '', action_id: '', host: '')
service.sign_url
```

</details>

<details>
<summary>Folders</summary>

### Folders

TODO: ...

</details>

<details>
<summary>Field Types</summary>

### Field Types

TODO: ...

</details>

<details>
<summary>Request Types</summary>

### Request Types

TODO: ...

</details>

<details>
<summary>Templates</summary>

### Templates

#### List templates

```ruby
# https://www.zoho.com/sign/api/template-managment/get-template-list.html

ZohoSign::Template::ListService.call(offset: 1, limit: 10).each do |facade|
  facade.description
end
```

Sort by column.

```ruby
ZohoSign::Template::ListService.call(sort_column: 'template_name', sort_order: 'ASC').map { _1 }
```

Filter by column.

```ruby
ZohoSign::Template::ListService.call(search_columns: { template_name: 'Eric Template' }).map { _1 }
```

Columns to sort and filter by are `template_name`, `owner_first_name` and `modified_time`.

#### Get a template

```ruby
# https://www.zoho.com/sign/api/template-managment/get-template-details.html

service = ZohoSign::Template::GetService.call(id: '')
service.description
service.document_fields
service.email_reminders
service.expiration_days
service.folder_name
service.folder_id
service.owner_email
service.template_name
service.request_status
...
```

#### Create a template

TODO: ...

#### Update a template

TODO: ...

#### Delete a template

TODO: ...

#### Create document from template

The auto filled fields specified in the `field_data` object should be marked as **Prefill by you** when creating the document template.

```ruby
# https://www.zoho.com/sign/api/template-managment/send-documents-using-template.html

ZohoSign::Template::Document::CreateService.call!(
  id: '',
  is_quicksend: true,
  data: {
    templates: {
      request_name: 'Request Document',
      field_data: {
        field_text_data: {
          'Full name' => 'Eric Cartman',
          'Email' => 'eric.cartman@example.com'
        },
        field_boolean_data: {
          'Agreed to terms' => true
        },
        field_date_data: {
          'Inception date' => '31/01/2025'
        }
      },
      actions: [{
        action_type: 'SIGN',
        recipient_email: 'eric.cartman@example.com',
        recipient_name: 'Eric Cartman',
        verify_recipient: false,
        delivery_mode: 'EMAIL',
        action_id: '',
        role: 'Client'
      }]
    }
  }
)
```

</details>

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kobusjoubert/zoho_sign.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
