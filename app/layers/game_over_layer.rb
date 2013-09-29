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
    options = defaults.merge(options)

    layer = self.layerWithColor([255, 255, 255, 255],
                                :width  => options[:width],
                                :height => options[:height])
    if options[:position]
      layer.position = options[:position]
    end

    message = won ? "You won!" : "You Lose :["
    window_size = CCDirector.sharedDirector.winSize
    label = Label.new(:text => message, :font_name => "Arial", :font_size => 32)
    label.color = [0, 0, 0]
    label.position = [window_size.width / 2, window_size.height / 2]
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
