require_relative "../errors"

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
      if rows.length == 0
        raise Errors::NotFound
      end

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
      if rows.length == 0
        raise Errors::NotFound
      end

      row = rows[0]

      fields = {
        ip: row[1],
        is_online: row[2],
        cert_issuer: row[3],
        cert_subject: row[4],
        cert_serial: row[5],
        cert_not_before: DateTime.parse(row[6]),
        cert_not_after: DateTime.parse(row[7]),
        response_body_length: row[8],
        created_at: row[9],
      }
      Status.new(fqdn, fields)
    end
  end
end
