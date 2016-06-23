require "lita"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require 'pulphelper/misc'
require 'pulphelper/repo'
require 'pulphelper/unit'
require "lita/handlers/pulp"

Lita::Handlers::Pulp.template_root File.expand_path(
  File.join("..", "..", "templates"),
 __FILE__
)
