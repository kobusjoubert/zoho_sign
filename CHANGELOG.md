## [0.1.7] - 2025-05-09

- README updates with links to API endpoint docs.
- `EmbedToken::GetService` path does not need to set the full path `/api/v1/requests/...` -> `requests/...`.
- README and Gemspec description updates.

## [0.1.6] - 2025-04-05

- Added `ZohoSign::GrantToken::GetService`.
- Set access token in `before_call` hook instead of lambda so we can capture errors from the access token service objects.
- Fixed empty list enumerable errors.
- Remove spec dependencies already included in `active_call-api`.

## [0.1.5] - 2025-04-03

- Refactor list endpoints to use `ZohoSign::Enumerable`.

## [0.1.4] - 2025-03-31

- Sign a document embedded link fix.

## [0.1.3] - 2025-03-25

- RubyGem badge
- Bug fix on method `forbidden?`

## [0.1.2] - 2025-03-25

- Refactored common REST API methods out into an active_call-api gem.

## [0.1.1] - 2025-03-22

- Add gem install instructions.

## [0.1.0] - 2025-03-09

- Initial release
