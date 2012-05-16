# Be sure to restart your server when you modify this file.

Failtastic::Application.config.session_store :cookie_store, :key => '_failtastic_session',
  :secret => 'd2fe5533b2ab4c10e54297bf94c02fa711aec68c685ba11f6a2c5e393bd9f38dcb5aafb2b414a341fd20ae8865d2a6ae973506f12588406172f7ae0e1961e595'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Failtastic::Application.config.session_store :active_record_store
