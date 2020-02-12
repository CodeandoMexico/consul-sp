module ActiveModel::Dates

  def parse_date(field, attrs)
    day, month, year = attrs["#{field}(1i)"],
                       attrs["#{field}(2i)"],
                       attrs["#{field}(3i)"]

    default_date = "1/Jan/2000".to_datetime
    return default_date unless day.present? && month.present? && year.present?
    Date.new(day.to_i, month.to_i, year.to_i)
  end

  def remove_date(field, attrs)
    attrs.except("#{field}(1i)", "#{field}(2i)", "#{field}(3i)")
  end

end
