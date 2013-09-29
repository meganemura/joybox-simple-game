class HelloWorldLayer < Joybox::Core::LayerColor

  scene

  def on_enter
    window_size = CCDirector.sharedDirector.winSize

    player = Sprite.new(:file_name => 'arts/player.png')
    player.position = [player.contentSize.width / 2, window_size.height / 2]

    self << player

    schedule('game_logic', :interval => 1)
  end

  def game_logic
    add_monster
  end

  def add_monster
    monster = Sprite.new(:file_name => 'arts/monster.png')

    # Determine where to spawn the monster along the Y axis
    window_size = CCDirector.sharedDirector.winSize
    min_y = monster.contentSize.height / 2
    max_y = window_size.height - monster.contentSize.height / 2
    range_y = max_y - min_y
    actual_y = rand() * range_y + min_y # See arc4random

    # Create the monster slightly off-screen along the right edge,
    # and along a random position along the Y axis as calculated above
    monster.position = [window_size.width + monster.contentSize.width / 2, actual_y]
    self << monster

    # Determine speed of the monster
    min_duration = 2.0
    max_duration = 4.0
    range_duration = max_duration - min_duration
    actual_duration = rand() * range_duration + min_duration

    # Create the actions
    action_move = Move.to(:position => [-monster.contentSize.width / 2, actual_y], :duration => actual_duration)
    action_move_done = Callback.with do |node|
      node.removeFromParent
    end

    sequence_action = Sequence.with(:actions => [action_move, action_move_done])
    monster.run_action(sequence_action)
  end
end
