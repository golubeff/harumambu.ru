class String
  def concat_with_encoding(value)
    concat_without_encoding(value.force_encoding(self.encoding))
  end
  alias_method_chain :concat, :encoding

  def escape_quotes
    self.gsub(/[']/, '\\\\\'')
  end
end
