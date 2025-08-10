# frozen_string_literal: true

require "timeout"

RSpec.describe(Tabs::Check::DNS::Resolver) do
  context ".new" do
    it "raises if no services" do
      expect { Tabs::Check::DNS::Resolver.new("doesntmatter") }.to(raise_error(Tabs::Check::DNS::Errors::ResolverServiceRequired))
    end
  end

  context ".ips" do
    it "resolves" do
      fqdn = "vds.io"
      r = Tabs::Check::DNS::Resolver.new(fqdn, dog: DNSResolverServiceMock.returning_ips(["1.2.3.9"]))
      ips = r.ips

      expect(ips).to(eq(["1.2.3.9"]))
    end

    context "using dog" do
      it "translates Dog::InvalidFQDN" do
        r = Tabs::Check::DNS::Resolver.new("doesntmatter", dog: DNSResolverServiceMock.raising(Dog::InvalidFQDN))
        expect { r.ips }.to(raise_error(Tabs::Check::DNS::Errors::InvalidFQDN))
      end

      it "translates Dog::NoResults" do
        r = Tabs::Check::DNS::Resolver.new("doesntmatter", dog: DNSResolverServiceMock.raising(Dog::NoResults))
        expect { r.ips }.to(raise_error(Tabs::Check::DNS::Errors::NoRecordsFound))
      end

      context "without dig" do
        it "handles Dog::BinaryUnavailable" do
          r = Tabs::Check::DNS::Resolver.new("doesntmatter", dog: DNSResolverServiceMock.raising(Dog::BinaryUnavailable))
          expect { r.ips }.to(raise_error(Tabs::Check::DNS::Errors::ServiceUnavailable))
        end
      end
    end

    context "using dig" do
      it "translates Dig::NoResults" do
        r = Tabs::Check::DNS::Resolver.new("doesntmatter", dig: DNSResolverServiceMock.raising(Dig::NoResults))
        expect { r.ips }.to(raise_error(Tabs::Check::DNS::Errors::NoRecordsFound))
      end

      it "translates Dig::BinaryUnavailable" do
        r = Tabs::Check::DNS::Resolver.new("doesntmatter", dig: DNSResolverServiceMock.raising(Dig::BinaryUnavailable))
        expect { r.ips }.to(raise_error(Tabs::Check::DNS::Errors::ServiceUnavailable))
      end

      it "translates Timeout::Error" do
        r = Tabs::Check::DNS::Resolver.new("doesntmatter", dig: DNSResolverServiceMock.raising(Timeout::Error))
        expect { r.ips }.to(raise_error(Tabs::Check::DNS::Errors::ServiceUnavailable))
      end
    end
  end
end
