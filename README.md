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

    $ rippler book_offers taker_pays:USD/bitstamp taker_gets:BTC/bitstamp

    $ rippler subscribe streams:[ledger]

Ripple server replies are returned as JSON and printed to stdout. If you want to do some post-processing of the results, get the source from Github and modify bin/rippler script.

## Usage: additional commands

Rippler also provides additional commands that print out human-readable output. You can use option -t for text (rather than structural) output.

    $ rippler -t order_book buy:BTC/bitstamp sell:XRP

This one prints current order book for any currency pair.

    $ rippler -t history account:molecular

This one prints any account history in a human-readable format.

    $ rippler balances account:bitstamp

This one prints out all outstanding balances (debit/credit IOUs and XRP) for a specific account. For example, you can see who holds Bitstamp BTC and fiat IOUs, and how much.

    $ rippler monitor streams:[ledger,transactions]

This one monitors Ripple transactions in real-time similar to #ripple-watch, but more interesting since it shows known account names instead of opaque addresses. Ctrl-C to stop it.

	$ rippler path_find source_account:RippleUnion destination_account:singpolyma 'destination_amount:{currency:CAD, value:1}'

This one finds possible paths for amounts of money between two addresses, and prints out what the source would have to send to get that amount to the destination.

## Contacts database

Contacts database is in lib/rippler/contacts.rb, mostly auto-scraped from Bitcointalk. It may be a bit inaccurate, you can modify/extend it as you see fit.

You may want to use 'bin/scraper' script to auto-scrape Ripple contacts from Bitcointalk topics:

    $ rippler https://bitcointalk.org/index.php?topic=145506.4100

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
