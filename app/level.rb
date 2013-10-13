class Level

  attr_accessor :level_num
  attr_accessor :secs_per_spawn
  attr_accessor :background_color

  def initialize(options = {})
    @level_num        = options[:level_num]
    @secs_per_spawn   = options[:secs_per_spawn]
    @background_color = options[:background_color]

    self
  end

end

class LevelManager

  attr_accessor :levels
  attr_accessor :current_level_index

  def self.new(options = {})
    initialize(options)
    instance
  end

  def self.instance
    Dispatch.once do
      @instance ||= alloc.init
    end
    @instance
  end

  def initialize(options = {})
    @current_level_index = 0
    level1 = Level.new({
      :level_num        => 1,
      :secs_per_spawn   => 2,
      :background_color => [255, 255, 255],
    })
    level2 = Level.new({
      :level_num        => 2,
      :secs_per_spawn   => 1,
      :background_color => [100, 150, 20],
    })
    self.levels = [level1, level2]

    return self
  end

  def current_level
    self.levels[current_level_index]
  end

  def next_level
    self.current_level_index += 1
  end

  def reset
    self.current_level_index = 0
  end

end
