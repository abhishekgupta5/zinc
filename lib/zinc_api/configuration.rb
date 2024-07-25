# frozen_string_literal: true

module ZincApi
  class << self
    extend Forwardable

    def_delegators :configuration, :client_token, :client_token=
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
    attr_accessor :client_token

    def initialize
      @client_token = nil
    end
  end
end
