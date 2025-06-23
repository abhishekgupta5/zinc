# frozen_string_literal: true

module ZincApi
  module Loggable
    private

    def log_message(level, class_name, message)
      return unless ZincApi.log_enabled
      Rails.logger.send(level, "[ZincApi #{class_name}] #{message}")
    end
  end
end
