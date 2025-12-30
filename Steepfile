# frozen_string_literal: true

D = Steep::Diagnostic

target :lib do
  signature "sig"
  signature "sig/vendor"

  check "lib"

  # Standard library type definitions
  library "json"
  library "securerandom"

  # Use default diagnostic levels (strict) but allow unannotated empty collections
  configure_code_diagnostics(D::Ruby.default.merge(
    D::Ruby::UnannotatedEmptyCollection => :information
  ))
end
