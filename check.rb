require "date"
require "json"
require "net/http"
require "openssl"
require "uri"

require "subprocess"

EXIT_CODE_USAGE = 1
EXIT_CODE_FAILURE = 2

args = ARGV

if args.length != 1
  puts "Usage: check <fqdn>"
  exit(EXIT_CODE_USAGE)
end

fqdn = args[0]

begin
  ip = Subprocess.check_output(["dog", "-1", fqdn]).strip!
rescue Subprocess::NonZeroExit => e
  puts e.message
  exit(EXIT_CODE_FAILURE)
end

uri = URI("https://#{fqdn}/")

event = {
  "fqdn": fqdn,
  "ip": ip,
  "uri": uri,
}

Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
  cert = OpenSSL::X509::Certificate.new (http.peer_cert)

  event = event.merge({
    "cert": {
      "subject": cert.subject,
      "issuer": cert.issuer,
      "serial": cert.serial,
      "not_before": cert.not_before,
      "not_after": cert.not_after,
    },
  })

  request = Net::HTTP::Get.new uri
  #  puts request
  request_started_at = DateTime::now()
  body_length = 0
  response_code = 0
  response_message = ""
  http.request(request) do |response|
    #    puts response.inspect
    response.read_body do |chunk|
      #      puts "chunky #{chunk}"
      body_length += chunk.length
    end
    response_code = response.code
    response_message = response.message
  end
  request_completed_at = DateTime::now()
  duration = request_completed_at - request_started_at
  duration_us = (duration * 24 * 60 * 60 * 1000 * 1000).to_i
  duration_ms = duration_us / 1000

  event = event.merge({
    "request": {
      "started_at": request_started_at,
      "completed_at": request_completed_at,
      "duration_us": duration_us,
      "duration_ms": duration_ms,
    },
    "response": {
      "code": response_code,
      "message": response_message,
      "body_length": body_length,
    },
  })
end

event_json = JSON.generate(event)
puts event_json
