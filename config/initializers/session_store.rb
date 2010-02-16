# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_talgud_session',
  :secret      => '5c0cbc508669ddf6a8a84553b1db785f9bbc59114becb0823297ad211f36bfe21f6085e7c816dee28b2eccb0b85026ce776a9740c1633aab34ea82f5b70b8170'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
