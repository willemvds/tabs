# frozen_string_literal: true

require "date"

require "hashdiff"

module Tabs
  module Domains
    module Migrations
      def self.migrate!(db)
        create_tables!(db)
        version = Tabs::Versions::Queries.version(db, "domains_statuses")
        if version < 2
          m2!(db)
        end

        if version < 3
          m3!(db)
        end
      end

      def self.create_tables!(db)
        create_domains_query = <<-SQL
          CREATE TABLE IF NOT EXISTS
            domains (
              fqdn VARCHAR(1000) PRIMARY KEY UNIQUE,
              created_at DATETIME NOT NULL
            )
        SQL
        db.execute(create_domains_query)

        create_statuses_query = <<-SQL
          CREATE TABLE IF NOT EXISTS domain_statuses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fqdn VARCHAR(1000) NOT NULL,
            ip VARCHAR(54),
            is_online BOOLEAN NOT NULL,
            cert_issuer VARCHAR(1000) NOT NULL,
            cert_subject VARCHAR(1000) NOT NULL,
            cert_serial VARCHAR(1000) NOT NULL,
            cert_not_before DATETIME NOT NULL,
            cert_not_after DATETIME NOT NULL,
            response_body_length INTEGER NOT NULL,
            created_at DATETIME NOT NULL,
            FOREIGN KEY(fqdn) REFERENCES domains(fqdn)
          )
        SQL
        db.execute(create_statuses_query)
      end

      def self.m2!(db)
        m2_query = <<-SQL
          ALTER TABLE domain_statuses
          ADD COLUMN kind INTEGER DEFAULT NULL
        SQL
        m2_query2 = <<-SQL
          ALTER TABLE domain_statuses
          ADD COLUMN cert_sans VARCHAR(1000) DEFAULT NULL
        SQL

        db.transaction do
          db.execute(m2_query)
          db.execute(m2_query2)
          Tabs::Versions::Commands.set!(db, "domains_statuses", 2)
        end
      end

      def self.m3!(db)
        m3_query = <<-SQL
          ALTER TABLE domain_statuses
          ADD COLUMN response_http_version VARCHAR(20) NOT NULL DEFAULT ''
        SQL
        m3_query2 = <<-SQL
          ALTER TABLE domain_statuses
          ADD COLUMN response_time_ms INTEGER DEFAULT 0
        SQL

        db.transaction do
          db.execute(m3_query)
          db.execute(m3_query2)
          Tabs::Versions::Commands.set!(db, "domains_statuses", 3)
        end
      end
    end
  end
end
