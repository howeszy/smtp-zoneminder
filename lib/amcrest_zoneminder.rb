# frozen_string_literal: true

class AmcrestZoneminder
  def self.redis
    @redis ||= ConnectionPool::Wrapper.new(size: 5, timeout: 3) { Redis.new(Rails.application.config_for(:redis)) }
  end
end
