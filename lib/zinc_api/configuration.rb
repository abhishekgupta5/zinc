# frozen_string_literal: true

module ZincApi
  class << self
    extend Forwardable

    def_delegators :configuration, :client_token, :client_token=
    def_delegators :configuration, :request_timeout, :request_timeout=
    def_delegators :configuration, :max_retries, :max_retries=
    def_delegators :configuration, :sleep_seconds, :sleep_seconds=
    def_delegators :configuration, :log_enabled, :log_enabled=
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  # Alias for backward compatibility
  def self.config
    configuration
  end

  class Configuration
    attr_accessor :client_token, :request_timeout,   :max_retries, :sleep_seconds, :log_enabled

    def initialize
      @client_token = nil
      @request_timeout = 10
      @max_retries = 3
      @sleep_seconds = 0.5
      @log_enabled = true
    end
  end
end
