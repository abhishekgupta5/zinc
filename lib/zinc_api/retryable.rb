# frozen_string_literal: true

require_relative "loggable"

module ZincApi
  module Retryable
    def self.included(base)
      base.include(ZincApi::Loggable)
    end
    
    def with_retry(max_attempts: ZincApi.max_retries, sleep_seconds: ZincApi.sleep_seconds)
      attempts = 0
      last_result = nil
      
      begin
        attempts += 1
        log_message(:info, "Retryable", "Attempt #{attempts}/#{max_attempts}")
        last_result = yield
        return last_result
      rescue ZincApi::Error => e
        # Only retry if we haven't reached max attempts
        if attempts < max_attempts
          log_message(:warn, "Retryable", "Attempt #{attempts} failed: #{e.class} - #{e.message}")
          log_message(:info, "Retryable", "Retrying in #{sleep_seconds} seconds...")
          sleep sleep_seconds
          retry
        else
          log_message(:error, "Retryable", "All #{max_attempts} attempts failed. Last error: #{e.class} - #{e.message}")
          # If we've exhausted all retries, check for outage condition first
          if e.response['code'] == 'internal_error' && e.response['message']&.include?('outages')
            log_message(:warn, "Retryable", "Detected Zinc outage, returning ZINC_DOWN")
            return { 'status' => "ZINC_DOWN" }
          end
          # Otherwise return the last result if we have one
          # or return response.parsed_response or response if available, or re-raise the error
          last_result || e.response || raise(e)
        end
      end
    end
  end
end
