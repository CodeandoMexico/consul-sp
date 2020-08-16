if ActiveRecord::Migrator.get_all_versions.include? "20190321032548"
  api_config = YAML.load_file('./config/api.yml')
  API_TYPE_DEFINITIONS = GraphQL::ApiTypesCreator::parse_api_config_file(api_config)
end
