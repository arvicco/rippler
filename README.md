# Rippler

Command line client for Ripple payment platform. It uses Ripple websocket API to send commands and receive responses.

## Installation

You need to have Ruby 1.9 (http://www.ruby-lang.org/en/downloads/) installed. Once Ruby is in place, just install Rippler gem:

    $ gem install rippler

Alternatively, you can install from source at Github:

    $ git clone https://github.com/arvicco/rippler.git
    $ cd rippler
    $ bundle install

## Usage: Ripple API

Rippler supports Ripple API commands (https://ripple.com/wiki/RPC_API). All parameters after command should be given in commandline JSON format, such as:

    $ rippler account_info account:rwLYfeQHfucz8wD6tFPY9Ms6ovmMBCCpMd

    $ rippler account_tx account:rwLYfeQHfucz8wD6tFPY9Ms6ovmMBCCpMd ledger:319841

    $ rippler account_tx account:evoorhees ledger_min:0 ledger_max:400000

    $ rippler subscribe streams:[ledger]

Ripple server replies are returned as JSON and printed to stdout. If you want to do some post-processing of the results, get the source from Github and modify bin/rippler script.

## Usage: additional commands

Rippler also provides additional commands that print out human-readable output:

    $ rippler history account:molecular

This one prints account history in a human-readable format.

    $ rippler monitor streams:[ledger,transactions]

This one monitors Ripple transactions in real-time similar to #ripple-watch, but more interesting since it shows known account names instead of opaque addresses. Ctrl-C to stop it.

## Contacts database

Contacts database is in lib/rippler/contacts.rb, mostly auto-scraped from Bitcointalk. It may be a bit inaccurate, you can modify/extend it as you see fit.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
