class Hash
  def map_values(&blk)
    arity = blk.arity
    self.each {|k,v| self[k] = arity == 2 ? yield(k, v) : yield(v) }
  end
end
