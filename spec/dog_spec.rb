# frozen_string_literal: true

RSpec.describe(Dog) do
  context ".ips" do
    it "returns the ip printed by the dog binary" do
      ip = "1.2.3.4"
      fakedog = FakeCLI.ok(stdout: ip)

      ips = Dog.ips("vds.io", fakedog)
      expect(ips).to(eq([ip]))
    end

    it "raises if the binary could not be executed" do
      expect { Dog.ips("doesntmatter", "thisbinarydoesnotexist") }.to(raise_error(Dog::BinaryUnavailable))
    end

    it "raises if the fqdn is not valid" do
      fakedog = FakeCLI.err(exitcode: Dog::EXITCODE_INVALID_QUERY)

      expect { Dog.ips("", fakedog) }.to(raise_error(Dog::InvalidFQDN))
    end

    it "raises if there are no results" do
      fakedog = FakeCLI.err(exitcode: Dog::EXITCODE_NO_RESULTS)

      expect { Dog.ips("", fakedog) }.to(raise_error(Dog::NoResults))
    end

    it "raises if there is an unknown exit code" do
      exitcode = 199
      stderr = "Got 199 problems"
      fakedog = FakeCLI.err(exitcode:, stderr:)

      expect { Dog.ips("", fakedog) }.to(raise_error(Dog::Error, /#{stderr}/))
    end
  end
end
