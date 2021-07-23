# frozen_string_literal: true

# Ruby's Hash class.
class ::Hash
  # Via https://stackoverflow.com/a/25835016/2257038
  def symbolize_keys
    h = map do |k, v|
      v_sym = v.instance_of?(Hash) ? v.symbolize_keys : v
      [k.to_sym, v_sym]
    end

    h.to_h
  end
end
