class ExportedDataCsv < ActiveRecord::Base
  has_attached_file :csv_file
  do_not_validate_attachment_file_type :csv_file
end
