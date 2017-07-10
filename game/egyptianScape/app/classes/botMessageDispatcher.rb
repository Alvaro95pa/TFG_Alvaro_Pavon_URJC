require 'gameMaster'
require 'heroe'

class BotMessageDispatcher
  attr_accessor :message, :user
  attr_reader :hero

  @@bot_command = nil

  def initialize(message, user)
    @message = message
    @user = user
    @hero = Heroe.new("Hero")
  end

  def process
    if (user.get_next_bot_command == "GameMaster::Start")
      if(@@bot_command == nil)
        @@bot_command = user.get_next_bot_command.safe_constantize.new(user, message, hero)
      end
      @@bot_command.message = message

      if (@@bot_command.should_start?)
        @@bot_command.start
      elsif (@@bot_command.gender?)
        @@bot_command.gender
      elsif (@@bot_command.start_game?)
        @@bot_command.start_game
      else
        unknown_command
      end

    elsif (user.get_next_bot_command == "GameMaster::Game")
      if(@@bot_command.instance_of?(GameMaster::Start))
        @@bot_command = user.get_next_bot_command.safe_constantize.new(user, message, hero)
      end
      @@bot_command.message = message

      if (@@bot_command.start?)
        @@bot_command.start
      elsif (@@bot_command.try_restart?)
        @@bot_command.try_restart
      elsif (@@bot_command.restarting?)
        @@bot_command.restarting
        if(user.get_next_bot_command == 'GameMaster::Start')
          @hero = Heroe.new("Hero")
          @@bot_command = user.get_next_bot_command.safe_constantize.new(user, message, hero)
        end
      elsif (@@bot_command.playing?)
        @@bot_command.playing
        if(@@bot_command.finPartida)
          @hero = Heroe.new("Hero")
          @@bot_command = user.get_next_bot_command.safe_constantize.new(user, message, hero)
        end
      else
        unknown_command
      end
      
    else
      @@bot_command = GameMaster::Start.new(user, message, hero)

      if (@@bot_command.should_start?)
        @@bot_command.start
      else
        unknown_command
      end
    end
  end

  private

  def unknown_command
    GameMaster::Undefined.new(user, message, hero).start
  end
end