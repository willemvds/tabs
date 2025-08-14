# frozen_string_literal: true

require "date"

require "hashdiff"

module Tabs
  module Domains
    module Commands
      VALID_FQDN_REGEX = /.+\..+/

      def self.create!(db, fqdn)
        raise Errors::ValidationFailed, "fqdn is not valid" unless fqdn.to_s.match(VALID_FQDN_REGEX)

        create_query = "
        INSERT INTO
          domains (fqdn, created_at)
        VALUES
          (?, ?)
      "
        created_at = Time.now.to_s
        begin
          db.execute(create_query, [fqdn, created_at])
        rescue SQLite3::ConstraintException
          raise Errors::EntityExists
        end

        Domain.new(fqdn, created_at)
      end

      UPDATE_DIFF_FIELDS = [
        :ip,
        :is_online,
        :cert_issuer,
        :cert_subject,
        :cert_serial,
        :cert_not_before,
        :cert_not_after,
        :response_body_length,
      ].freeze

      def self.update_status!(db, fqdn, new_fields)
        begin
          current = Queries.status_by_fqdn(db, fqdn)
          old_fields = {
            ip: current.ip,
            is_online: current.online?,
            cert_issuer: current.cert_issuer,
            cert_subject: current.cert_subject,
            cert_serial: current.cert_serial,
            cert_not_before: current.cert_not_before,
            cert_not_after: current.cert_not_after,
            response_body_length: current.response_body_length,
          }
        rescue Errors::NotFound
          old_fields = {}
        end

        diff = Hashdiff.diff(new_fields, old_fields)
        if diff.empty?
          new_fields[:created_at] = current.created_at
          return Status.new(fqdn, new_fields)
        end

        create_status_query = "
        INSERT INTO
          domain_statuses (
            fqdn,
            ip,
            is_online,
            cert_issuer,
            cert_subject,
            cert_serial,
            cert_not_before,
            cert_not_after,
            response_body_length,
            created_at
          )
        VALUES
          (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      "

        new_values = UPDATE_DIFF_FIELDS.map do |field|
          v = new_fields.fetch(field)
          v = v.to_s if [:cert_not_before, :cert_not_after].include?(field)
          if field == :is_online
            v = v ? Status::ONLINE : Status::OFFLINE
          end
          v
        end
        created_at = Time.now
        new_values = [fqdn] + new_values + [created_at.to_s]
        db.execute(create_status_query, new_values)
      end

      def self.create_tables!(db)
        create_domains_query = "
        CREATE TABLE IF NOT EXISTS
          domains (
            fqdn VARCHAR(1000) PRIMARY KEY UNIQUE,
            created_at DATETIME NOT NULL
          )
      "

        db.execute(create_domains_query)

        create_statuses_query = "
        CREATE TABLE IF NOT EXISTS
          domain_statuses (
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
      "
        db.execute(create_statuses_query)
      end
    end
  end
end
