# frozen_string_literal: true

D = Steep::Diagnostic

target :lib do
  signature "sig"
  signature "sig/vendor"

  check "lib"

  # Standard library type definitions
  library "json"
  library "securerandom"

  # Use default diagnostic levels (strict)
  configure_code_diagnostics(D::Ruby.default)
end
