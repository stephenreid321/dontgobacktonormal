class Alternative < Airrecord::Table
  self.base_key = ENV['AIRTABLE_BASE_KEY']
  self.table_name = self.to_s.underscore.humanize.pluralize
end