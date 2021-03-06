class StarTrekCLI::Episode
  attr_reader :name, :air_date, :star_date, :production_number, :season

  @@all = []

  def initialize(season, production_number, name, star_date, air_date, script = nil)
    @season = season
    @name = name
    @production_number = production_number
    @star_date = star_date
    @air_date = air_date
    @@all << self
    raise "episode.new was called with an int and not a string" unless production_number.is_a? String
    season.episodes[production_number] = self
  end

  def self.all
    @@all
  end

end
