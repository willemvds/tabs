# frozen_string_literal: true

RSpec.describe(Tabs::Domains::Status) do
  describe ".wildcard?" do
    it "assumes no wildcard by default" do
      status = Tabs::Domains::Status.new("fqdn", {
        ip: "",
        is_online: false,
        cert_issuer: "",
        cert_subject: "/CN=*.vds.io",
        cert_serial: "",
        cert_not_before: nil,
        cert_not_after: nil,
        cert_sans: "",
        response_body_length: 0,
        created_at: nil,
      })

      expect(status.wildcard?).to(be(true))
    end

    it "correctly identifies wildcards" do
      status = Tabs::Domains::Status.new("fqdn", {
        ip: "",
        is_online: false,
        cert_issuer: "",
        cert_subject: "/CN=*.vds.io",
        cert_serial: "",
        cert_not_before: nil,
        cert_not_after: nil,
        cert_sans: "",
        response_body_length: 0,
        created_at: nil,
      })

      expect(status.wildcard?).to(be(true))
    end
  end
end
