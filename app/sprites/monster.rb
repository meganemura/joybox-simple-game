class Monster < Joybox::Core::Sprite

  attr_accessor :hp
  attr_reader   :min_move_duration
  attr_reader   :max_move_duration

  def initialize(options = {})
    object = super(:file_name => options[:file_name])

    @hp = options[:hp]
    @min_move_duration = options[:min_move_duration]
    @max_move_duration = options[:max_move_duration]

    object
  end

end

class WeakAndFastMonster < Monster

  def initialize(options = {})
    super({
      :file_name          => 'arts/monster.png',
      :hp                 => 1,
      :min_move_duration  => 3,
      :max_move_duration  => 5,
    })
  end

end

class StrongAndSlowMonster < Monster

  def initialize(options = {})
    super({
      :file_name          => 'arts/monster2.png',
      :hp                 => 3,
      :min_move_duration  => 6,
      :max_move_duration  => 12,
    })
  end

end
