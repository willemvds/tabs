RSpec.describe Tabs::Domains::Commands do
  include_context 'db'

  context '.create!' do
    it 'validates the fqdn' do
      fqdn = 42
      expect { Tabs::Domains::Commands.create!(@test_db, fqdn) }.to raise_error(Tabs::Errors::ValidationFailed)
    end

    it 'creates a domain' do
      fqdn = 'nobody.nothing'
      domain = Tabs::Domains::Commands.create!(@test_db, fqdn)

      expect(domain.fqdn).to eq fqdn
    end

    it 'prevents duplicates' do
      fqdn = 'somebody.something'
      Tabs::Domains::Commands.create!(@test_db, fqdn)

      expect { Tabs::Domains::Commands.create!(@test_db, fqdn) }.to raise_error(Tabs::Errors::EntityExists)
    end
  end
end
