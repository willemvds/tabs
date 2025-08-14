# frozen_string_literal: true

module Tabs
  module Domains
    module Queries
      def self.by_fqdn(db, fqdn)
        by_fqdn_query = "
        SELECT
          fqdn, created_at
        FROM
          domains
        WHERE
          fqdn=?
        LIMIT
          1
      "
        rows = db.execute(by_fqdn_query, fqdn)
        raise Errors::NotFound if rows.empty?

        Domain.new(rows[0][0], rows[0][1])
      end

      def self.status_by_fqdn(db, fqdn)
        status_by_fqdn_query = "
        SELECT
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
        FROM
          domain_statuses
        WHERE
          fqdn = ?
        ORDER BY
          created_at DESC
        LIMIT
          1
      "
        rows = db.execute(status_by_fqdn_query, fqdn)
        raise Errors::NotFound if rows.empty?

        row = rows[0]

        fields = {
          ip: row[1],
          is_online: row[2] != 0,
          cert_issuer: row[3],
          cert_subject: row[4],
          cert_serial: row[5],
          cert_not_before: Time.parse(row[6]),
          cert_not_after: Time.parse(row[7]),
          response_body_length: row[8],
          created_at: row[9],
        }
        Status.new(fqdn, fields)
      end

      def self.most_recent_statuses(db)
        most_recent_statuses_query = "
        SELECT
          domains.fqdn,
          ip,
          is_online,
          cert_issuer,
          cert_subject,
          cert_serial,
          cert_not_before,
          cert_not_after,
          response_body_length,
          domain_statuses.created_at
        FROM
          domains
        INNER JOIN
          domain_statuses
          ON domains.fqdn = domain_statuses.fqdn
        WHERE
          domain_statuses.created_at = (
            SELECT
              MAX(created_at)
            FROM
              domain_statuses
            WHERE
              domain_statuses.fqdn = domains.fqdn
          )
      "

        rows = db.execute(most_recent_statuses_query)
        rows.map do |row|
          fields = {
            ip: row[1],
            is_online: row[2] != 0,
            cert_issuer: row[3],
            cert_subject: row[4],
            cert_serial: row[5],
            cert_not_before: Time.parse(row[6]),
            cert_not_after: Time.parse(row[7]),
            response_body_length: row[8],
            created_at: row[9],
          }
          Status.new(row[0], fields)
        end
      end
    end
  end
end
