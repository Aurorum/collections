class LocalRestriction
  attr_reader :gss_code

  def initialize(gss_code)
    @gss_code = gss_code
  end

  def all_restrictions
    @all_restrictions ||= YAML.load_file(file_name)
  end

  def restriction
    all_restrictions[gss_code] || {}
  end

  def file_name
    "lib/local_restrictions/local-restrictions.yaml"
  end

  def area_name
    restriction["name"]
  end

  def alert_level
    restriction["alert_level"]
  end

  def current
    restrictions = restriction["restrictions"]
    restrictions.select { |rest| rest["start_date"].to_date.past? }
                .max_by { |rest| rest["start_date"] }
  end

  def future
    restrictions = restriction["restrictions"]
    restrictions.select { |rest| rest["start_date"].to_date.future? }
                .min_by { |rest| rest["start_date"] }
  end
end
