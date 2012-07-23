# Failtastic
Failtastic helps aggregate and display test failures at Meraki. A script polls your email IMAP,
aggregates, and inserts into a DB.  A rails app then displays all outstanding failures.

### Setting up a devel checkout
1. Install ruby 1.9.3 (I recommend using rvm)
1. run bundle install
1. Create a db (rake db:migrate)
1. Create config/mail.yml (ask grant for the failbot account credentials)
1. Populate the DB with human replies going back a long way
    ruby script/mail_fetch.rb --fast --start "Apr 1 2012"
1. Populate teh DB with test failures going back only a few weeks
    ruby script/mail_fetch.rb --start "Jul 1"
1. Start the server (rails s)