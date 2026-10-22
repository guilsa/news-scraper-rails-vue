require "logger"
require "minitest/autorun"
require "minitest/mock"
require "active_record"
require "action_controller"
require "rack/mock"
require_relative "../app/controllers/application_controller"
require_relative "../app/controllers/health_controller"

class HealthCheckTest < Minitest::Test
  Pool = Struct.new(:connection) do
    def with_connection
      yield connection
    end
  end

  def request_with(pool)
    ActiveRecord::Base.stub(:connection_pool, pool) do
      HealthController.action(:show).call(Rack::MockRequest.env_for("/healthz"))
    end
  end

  def test_healthy_database_returns_empty_200_without_loading_articles
    connection = Minitest::Mock.new
    connection.expect(:select_value, 1, ["SELECT 1"])

    status, _, body = request_with(Pool.new(connection))

    assert_equal 200, status
    chunks = []
    body.each { |chunk| chunks << chunk }
    assert_equal "", chunks.join
    connection.verify
  end

  def test_database_connection_failure_returns_503
    connection = Object.new
    def connection.select_value(_sql)
      raise ActiveRecord::ConnectionNotEstablished, "database unavailable"
    end

    status, _, _ = request_with(Pool.new(connection))

    assert_equal 503, status
  end

  def test_connection_pool_exhaustion_returns_503
    pool = Object.new
    def pool.with_connection
      raise ActiveRecord::ConnectionTimeoutError, "pool exhausted"
    end

    status, _, _ = request_with(pool)

    assert_equal 503, status
  end
end
