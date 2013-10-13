class HelloWorldLayer < Joybox::Core::LayerColor

  scene

  def self.new(options = {})
    level_manager = LevelManager.instance
    options = options.merge(:color => level_manager.current_level.background_color)
    super(options)
  end

  def on_enter
    @monsters = []
    @monster_destroyed = 0

    @projectiles = []
    @next_projectile = nil

    @player = Sprite.new(:file_name => 'arts/player2.png')
    @player.position = [@player.contentSize.width.half, Screen.half_height]

    self << @player

    schedule('game_logic', :interval => 1.0)
    schedule('update')

    background_audio = BackgroundAudio.new
    background_audio.add(:audio => :background_music, :file_name => 'sounds/background-music-aac.caf')
    background_audio.play(:background_music)

    on_touches_ended do |touches, event|
      shoot_projectile(touches)
    end
  end

  def game_logic
    add_monster
  end

  def update
    projectiles_to_delete = []
    @projectiles.each do |projectile|
      monster_hit = false
      monsters_to_delete = []
      @monsters.each do |monster|
        if CGRectIntersectsRect(projectile.boundingBox, monster.boundingBox)
          monster_hit = true
          monster.hp -= 1
          if monster.hp <= 0
            monsters_to_delete << monster
          end
          break
        end
      end

      monsters_to_delete.each do |monster|
        @monsters.delete(monster)
        self.removeChild(monster)
        @monster_destroyed += 1
        if @monster_destroyed > 30
          game_over_scene = GameOverLayer.scene_with_won(true)
          Joybox.director.replaceScene(game_over_scene)
        end
      end

      if monster_hit
        projectiles_to_delete << projectile

        audio_effect = AudioEffect.new
        audio_effect.add(:effect => :explosion, :file_name => 'sounds/explosion.caf')
        audio_effect.play(:explosion)
      end
    end

    projectiles_to_delete.each do |projectile|
      @projectiles.delete(projectile)
      self.removeChild(projectile)
    end
  end

  def add_monster
    if rand(2) == 0
      monster = WeakAndFastMonster.new
    else
      monster = StrongAndSlowMonster.new
    end
    monster.tag = 1
    @monsters << monster

    # Determine where to spawn the monster along the Y axis
    min_y = monster.contentSize.height.half
    max_y = Screen.height - monster.contentSize.height.half
    range_y = max_y - min_y
    actual_y = rand() * range_y + min_y # See arc4random

    # Create the monster slightly off-screen along the right edge,
    # and along a random position along the Y axis as calculated above
    monster.position = [Screen.width + monster.contentSize.width.half, actual_y]
    self << monster

    # Determine speed of the monster
    min_duration = monster.min_move_duration
    max_duration = monster.max_move_duration
    range_duration = max_duration - min_duration
    actual_duration = rand() * range_duration + min_duration

    # Create the actions
    move_action = Move.to(:position => [-monster.contentSize.width.half, actual_y], :duration => actual_duration)
    move_action_done = Callback.with do |node|
      @monsters.delete(node)
      node.removeFromParent
      game_over_scene = GameOverLayer.scene_with_won(false)
      Joybox.director.replaceScene(game_over_scene)
    end

    move_sequence = Sequence.with(:actions => [move_action, move_action_done])
    monster.run_action(move_sequence)
  end

  def shoot_projectile(touches)

    return if @next_projectile

    # Choose one of the touches to work with
    touch = touches.any_object
    location = self.convertTouchToNodeSpace(touch)

    # Set up initial location of projectile
    @next_projectile = Sprite.new(:file_name => 'arts/projectile2.png')
    @next_projectile.position = [20, Screen.half_height]

    # Determine offset of location to projectile
    offset = location - @next_projectile.position

    # Bail out if you are shooting down or backwards
    return if offset.x <= 0

    # Determine where you wish to shoot the projectile to
    real_x = Screen.width + @next_projectile.contentSize.width.half
    ratio = offset.y.to_f / offset.x
    real_y = real_x * ratio + @next_projectile.position.y
    real_dest = [real_x, real_y]

    # Determine the length of how far you're shooting
    off_real_x = real_x - @next_projectile.position.x
    off_real_y = real_y - @next_projectile.position.y
    length = Math.sqrt(off_real_x**2 + off_real_y**2)
    velocity = 480 / 1  # 480 pixels/second
    real_move_duration = length / velocity

    # Determine angle to face
    angle_radians = jbpToAngle(jbp(off_real_x, off_real_y))
    angle_degrees = angle_radians / Math::PI * 180.0  # TODO: Add macro to joybox: `motion/joybox/macros.rb`
    angle = -1 * angle_degrees
    rotate_degrees_per_second = 180 / 0.5   # Would take 0.5 seconds to rotate 180 degrees, or half a circle
    degrees_diff = @player.rotation - angle
    rotate_duration = (degrees_diff / rotate_degrees_per_second).abs

    rotate_action = Rotate.to(:angle => angle, :duration => rotate_duration)
    rotate_action_done = Callback.with do |node|
      # OK to add now - rotation is finished!
      self << @next_projectile
      @projectiles << @next_projectile
      @next_projectile = nil
    end
    rotate_sequence = Sequence.with(:actions => [rotate_action, rotate_action_done])
    @player.run_action(rotate_sequence)

    # Move projectile to actual endpoint
    move_action = Move.to(:position => real_dest, :duration => real_move_duration)
    move_action_done = Callback.with do |node|
      @projectiles.delete(node)
      node.removeFromParent
    end
    move_sequence = Sequence.with(:actions => [move_action, move_action_done])
    @next_projectile.run_action(move_sequence)

    @next_projectile.tag = 2

    audio_effect = AudioEffect.new
    audio_effect.add(:effect => :pew_pew_lei, :file_name => 'sounds/pew-pew-lei.caf')
    audio_effect.play(:pew_pew_lei)
  end
end
