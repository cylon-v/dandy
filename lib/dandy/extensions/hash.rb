class Hash
  # simplecov incorrectly covers activesupport variants of these overloads.
  # Actually both methods are covered by unit tests.

  # :nocov:
  def symbolize_keys
    Hash[map{|(k,v)| [k.to_sym,v]}]
  end

  def deep_symbolize_keys!
    keys.each do |key|
      val = delete(key)
      self[(key.to_sym rescue key)] = val.is_a?(Hash) || val.is_a?(Array) ? val.deep_symbolize_keys! : val
    end
    self
  end
  # :nocov:
end