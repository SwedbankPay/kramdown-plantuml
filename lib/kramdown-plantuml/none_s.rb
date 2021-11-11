# frozen_string_literal: true

# Ruby's Object class.
class Object
  # Performs a case insensitive, trimmed comparison of the Object and the
  # String 'none' and Symbol :none. Returns true if the comparison is true,
  # otherwise false.
  #
  # @return [Boolean] True if the Object is equal to 'none' or :none,
  # otherwise false.
  def none_s?
    return false if nil?
    return true if self == :none

    to_s.strip.casecmp?('none')
  end
end
