class HelloWorldLayer < Joybox::Core::LayerColor

  scene

  def on_enter
    window_size = CCDirector.sharedDirector.winSize

    player = Sprite.new(:file_name => 'arts/player.png')
    player.position = [player.contentSize.width / 2, window_size.height / 2]

    self << player
  end
end
