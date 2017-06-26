require 'telegram/bot'
require 'rubyplay_framework'
require 'heroe'

module GameMaster
  class Base
    attr_reader :user, :message, :api, :hero
    attr_accessor :inicio, :endGame

    def initialize(user, message)
      @user = user
      @message = message
      token = Rails.application.secrets.bot_token
      @api = ::Telegram::Bot::Api.new(token)
      @hero = Heroe::Heroe.new("Hero")
      @inicio = MapPoint::Point.new(0, -10, -1)
      @endGame = false
    end

    def should_start?
      raise NotImplementedError
    end

    def start
      raise NotImplementedError
    end

    protected

    def send_message(text, markup = nil)
      if(markup != nil)
        @api.call('sendMessage', chat_id: @user.telegram_id, text: text, reply_markup: markup)
      else
        @api.call('sendMessage', chat_id: @user.telegram_id, text: text)
      end
    end

    def text
      @message[:message][:text]
    end

    def from
      @message[:message][:from]
    end
  end

  ##################
  class Start < Base
    def should_start?
      text =~ /\A\/start/
    end

    def start
      keyboard = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['Comenzar'], one_time_keyboard: true)
      send_message('¡Te doy la bienvenida a EgyptianScape!', keyboard)

      user.reset_next_bot_command
      user.set_next_bot_command('GameMaster::Comenzar')    
    end
  end

  #################
  class Comenzar < Base
    def should_start?
      text =~ /Comenzar/
    end

    def continue?
      text =~ /Chico|Chica/
    end

    def start
      keyboard = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['Chico', 'Chica'], one_time_keyboard: true)
      send_message("¿Eres un chico o una chica?", keyboard)
      user.reset_next_bot_command
      user.set_next_bot_command('GameMaster::Comenzar')  
    end

    def continue
      hero.gender = text
      kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      send_message("Introduce tu nombre:", kb)
      user.reset_next_bot_command
      user.set_next_bot_command('GameMaster::Comenzar')  
    end

    def adventure_time?
      text =~ /\w+/
    end

    def adventure_time
      user.reset_next_bot_command
      hero.nametag = text
      send_message("Buena suerte #{@hero.nametag}")
      user.set_next_bot_command('GameMaster::Game')
    end

  end

  #################
  class Game < Base

    include RubyplayFramework

    def should_start?
      !(endGame)
    end

    def start
      i = init_Interpreter()
      i.intialize_functions("app/assets/config/comandos.txt")
      buildMap = init_Map()
      buildMap.build_map("app/assets/config/pyramidMap.xml")
      map = buildMap.map()
      p1 = MapPoint::Point.new(0, -10, 3)
      p2 = MapPoint::Point.new(0, -10, 4)
      map.delete_adjacent(p1, p2)
      
      map.map_nodes().each { |key, value| send_message("#{key} -> #{value}") }
      endGame = true
      
      if(endGame)
        user.set_next_bot_command('GameMaster::Start')
      else
        user.set_next_bot_command('GameMaster::Game')
      end
      #i.parse(text)
    end

  end

  ######################
  class Undefined < Base
    def start
      send_message('Comando desconocido. Asegurate de introducir el comando correcto')
    end
  end
end
