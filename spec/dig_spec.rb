# frozen_string_literal: true

RSpec.describe(Dig) do
  context ".ips" do
    it "returns the ip printed by the dig binary" do
      ip = "192.168.222.111"
      fakedig = FakeCLI.ok(stdout: ip)

      ips = Dig.ips("vds.io", fakedig)
      expect(ips).to(eq([ip]))
    end

    it "raises if the binary could not be executed" do
      expect { Dig.ips("doesntmatter", "thisbinarydoesnotexist") }.to(raise_error(Dig::BinaryUnavailable))
    end

    it "raises if there are no results" do
      fakedig = FakeCLI.ok(stdout: "")

      expect { Dig.ips("", fakedig) }.to(raise_error(Dig::NoResults))
    end

    it "raises if there is an unknown exit code" do
      exitcode = 222
      stderr = "NEVER SEEN THIS BEFORE"
      fakedig = FakeCLI.err(exitcode:, stderr:)

      expect { Dig.ips("", fakedig) }.to(raise_error(Dig::Error, /#{stderr}/))
    end
  end
end
