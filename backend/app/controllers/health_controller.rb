class HealthController < ApplicationController
  def show
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      connection.select_value("SELECT 1")
    end

    head :ok
  rescue ActiveRecord::ActiveRecordError
    head :service_unavailable
  end
end
