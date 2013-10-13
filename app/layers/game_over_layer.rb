class GameOverLayer < Joybox::Core::LayerColor

  def self.scene
    define_singleton_method(:scene_with_won) do |won, options = {}|
      scene = CCScene.new
      layer = self.new(won, options)
      scene << layer
    end
  end

  scene

  def self.new(won, options)
    options = defaults.merge(options).merge(:color => [255, 255, 255])
    layer = super(options)

    if won
      LevelManager.instance.next_level
      current_level = LevelManager.instance.current_level
      if current_level
        message = "Get ready for level #{current_level.level_num}!"
      else
        message = "You Won!"
        LevelManager.instance.reset
      end
    else
      message = "You Lose :["
      LevelManager.instance.reset
    end

    label = Label.new(:text => message, :font_name => "Arial", :font_size => 32)
    label.color = [0, 0, 0]
    label.position = Screen.center
    layer << label

    delay_action = Delay.time(:by => 3.0)
    delay_action_done = Callback.with do |node|
      Joybox.director.replaceScene(HelloWorldLayer.scene(:color => "FFFFFF".to_color))
    end
    action_sequence = Sequence.with(:actions => [delay_action, delay_action_done])
    layer.run_action(action_sequence)

    layer
  end


end
