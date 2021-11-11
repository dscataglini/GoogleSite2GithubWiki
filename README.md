# GoogleSiteToGithubWiki

It converts a Google Classic Site takeout export to a Github Wiki markdown compatible format.

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'google_site_to_github_wiki'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install google_site_to_github_wiki

## Usage

Example code:

    GoogleSiteToGithubWiki.new(source_path_, 
                               output_path_, 
                               replace_page_paths: {'home.html' => 'gsite.md' }, 
                               debug: true, 
                               content_selector: '.sites-layout-name-one-column', 
                               create_sidebars: true).convert!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dscataglini/GoogleSiteToGithubWiki. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GoogleSiteToGithubWiki project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/dscataglini/GoogleSiteToGithubWiki/blob/master/CODE_OF_CONDUCT.md).
