# frozen_string_literal: true

ROOT_DIR = File.dirname(__FILE__).freeze

loader = Zeitwerk::Loader.new

# This is copied from official docs but does not work in current form.
loader.inflector.inflect(
  'rabbit_mq': 'RabbitMQ'
)

loader.push_dir(File.join(ROOT_DIR, 'lib'))
loader.push_dir(File.join(ROOT_DIR, 'ui'))

loader.setup
loader.eager_load
