class GenerateCsvJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    new_file = Tempfile.new(['reporte', '.csv'])
    file = User.all.to_csv
    new_file.write(file)
    report = ExportedDataCsv.new
    report.csv_file = new_file
    report.save
    new_file.close
    new_file.unlink
  end
end
