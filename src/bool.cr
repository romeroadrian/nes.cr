struct Bool
  def to_u8
    self ? 1_u8 : 0_u8
  end
end
