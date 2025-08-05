require 'fileutils'
require 'securerandom'

module FakeCLI
  EXITCODE_OK = 0

  def self.make(exitcode:, stdout:, stderr:)
    random_hex_name = SecureRandom.hex(20)
    fakecli = File.join(TEST_SCRATCH_DIR, "#{random_hex_name}.sh")
    File.write(fakecli,
               "#!/usr/bin/env bash\necho \"#{stdout}\"\necho \"#{stderr}\" >&2\nexit #{exitcode}")
    File.chmod(0o700, fakecli)
    fakecli
  end

  def self.ok(stdout: '', stderr: '')
    FakeCLI.make(exitcode: EXITCODE_OK, stdout:, stderr:)
  end

  def self.err(exitcode:, stdout: '', stderr: '')
    FakeCLI.make(exitcode:, stdout:, stderr:)
  end
end
