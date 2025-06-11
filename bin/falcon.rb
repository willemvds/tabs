# frozen_string_literal: true

require "falcon/environment/rack"
require "falcon/environment/supervisor"

hostname = "vds.io"

service hostname do
  include Falcon::Environment::Rack

  endpoint do
    Async::HTTP::Endpoint
      .parse("http://localhost:9292")
      .with(protocol: Async::HTTP::Protocol::HTTP11)
  end
end

service "supervisor" do
  include Falcon::Environment::Supervisor
end
