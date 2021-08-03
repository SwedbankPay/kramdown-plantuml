# frozen_string_literal: true

# Ruby's Hash class.
class ::Hash
  # Via https://stackoverflow.com/a/25835016/2257038
  def symbolize_keys
    array = map do |key, value|
      value = value.instance_of?(Hash) ? value.symbolize_keys : value
      [key.to_sym, value]
    end

    array.to_h
  end
end
