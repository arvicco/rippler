# Rippler

Command line client for Ripple payment platform. It uses Ripple websocket API to send commands and receive responses.

## Installation

You need to have Ruby 1.9 (http://www.ruby-lang.org/en/downloads/) installed. Once Ruby is in place, just install Rippler gem:

    $ gem install rippler

## Usage

Rippler supports Ripple API commands (https://ripple.com/wiki/RPC_API). All parameters after command should be given in JSON format, such as:

    $ rippler account_info ident:rpvfJ4mR6QQAeogpXEKnuyGBx8mYCSnYZi

    $ rippler account_tx account:rpvfJ4mR6QQAeogpXEKnuyGBx8mYCSnYZi ledger:319841

    $ rippler account_tx account:rpH3zuMch2GrrYX724xGWwbMGwiQ5RbSAU ledger_min:300000 ledger_max:319000

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
