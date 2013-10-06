class HelloWorldLayer < Joybox::Core::LayerColor

  scene

  def on_enter
    @monsters = []
    @projectiles = []
    @monster_destroyed = 0

    player = Sprite.new(:file_name => 'arts/player2.png')
    player.position = [player.contentSize.width.half, Screen.half_height]

    self << player

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
      monsters_to_delete = []
      @monsters.each do |monster|
        if CGRectIntersectsRect(projectile.boundingBox, monster.boundingBox)
          monsters_to_delete << monster
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

      if monsters_to_delete.size > 0
        projectiles_to_delete << projectile
      end
    end

    projectiles_to_delete.each do |projectile|
      @projectiles.delete(projectile)
      self.removeChild(projectile)
    end
  end

  def add_monster
    monster = Sprite.new(:file_name => 'arts/monster.png')
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
    min_duration = 2.0
    max_duration = 4.0
    range_duration = max_duration - min_duration
    actual_duration = rand() * range_duration + min_duration

    # Create the actions
    action_move = Move.to(:position => [-monster.contentSize.width.half, actual_y], :duration => actual_duration)
    action_move_done = Callback.with do |node|
      @monsters.delete(node)
      node.removeFromParent
      game_over_scene = GameOverLayer.scene_with_won(false)
      Joybox.director.replaceScene(game_over_scene)
    end

    sequence_action = Sequence.with(:actions => [action_move, action_move_done])
    monster.run_action(sequence_action)
  end

  def shoot_projectile(touches)

    # Choose one of the touches to work with
    touch = touches.any_object
    location = self.convertTouchToNodeSpace(touch)

    # Set up initial location of projectile
    projectile = Sprite.new(:file_name => 'arts/projectile2.png')
    projectile.position = [20, Screen.half_height]
    projectile.tag = 2
    @projectiles << projectile

    # Determine offset of location to projectile
    offset = location - projectile.position

    # Bail out if you are shooting down or backwards
    return if offset.x <= 0

    # Ok to add now - we've double checked position
    self << projectile

    real_x = Screen.width + projectile.contentSize.width.half
    ratio = offset.y.to_f / offset.x
    real_y = real_x * ratio + projectile.position.y
    real_dest = [real_x, real_y]

    # Determine the length of how far you're shooting
    off_real_x = real_x - projectile.position.x
    off_real_y = real_y - projectile.position.y
    length = Math.sqrt(off_real_x**2 + off_real_y**2)
    velocity = 480 / 1  # 480 pixels/second
    real_move_duration = length / velocity

    # Move projectile to actual endpoint
    action_move = Move.to(:position => real_dest, :duration => real_move_duration)
    action_move_done = Callback.with do |node|
      @projectiles.delete(node)
      node.removeFromParent
    end
    sequence_action = Sequence.with(:actions => [action_move, action_move_done])
    projectile.run_action(sequence_action)

    audio_effect = AudioEffect.new
    audio_effect.add(:effect => :pew_pew_lei, :file_name => 'sounds/pew-pew-lei.caf')
    audio_effect.play(:pew_pew_lei)
  end
end
