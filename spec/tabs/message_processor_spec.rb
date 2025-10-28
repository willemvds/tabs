# frozen_string_literal: true

RSpec.describe(Tabs::MessageProcessor) do
  context "#process" do
    mp = Tabs::MessageProcessor.new do |fqdn, updates|
      [fqdn, updates]
    end

    it "builds updates correctly" do
      msg = {
        fqdn: "this.n.that",
        cert: {
          issuer: "Nobody",
          subject: "Somebody",
          serial: "Everybody",
          not_before: "2024-12-31",
          not_after: "2025-12-31",
          sans: "DNS:this.n.that,DNS:www.this.n.that",
        },
        response: {
          code: 200,
          body_length: 0,
        },
        ips: [5, 4, 1, 2, 3],
      }

      pr = mp.process(msg)

      expected_fields_param = {
        ip: 1,
        is_online: true,
        cert_issuer: msg[:cert][:issuer],
        cert_subject: msg[:cert][:subject],
        cert_serial: msg[:cert][:serial],
        cert_not_before: Time.parse(msg[:cert][:not_before]),
        cert_not_after: Time.parse(msg[:cert][:not_after]),
        cert_sans: msg[:cert][:sans],
        response_body_length: msg[:response][:body_length],
      }
      expect(pr).to(eq([msg[:fqdn], expected_fields_param]))
    end
  end
end
