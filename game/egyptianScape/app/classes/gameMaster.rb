require 'telegram/bot'
require 'rubyplay_framework'
require 'heroe'
require 'cofre'

module GameMaster

  class Base
    include RubyplayFramework

    attr_accessor :user, :message, :finPartida
    attr_reader :api, :hero

    def initialize(user, message, hero)
      @user = user
      @message = message
      token = Rails.application.secrets.bot_token
      @api = ::Telegram::Bot::Api.new(token)
      @hero = hero
      @mapa = init_Map()
      @interprete = init_Interpreter()
      @finPartida = false
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
    
    def gender?
      text =~ /Chico|Chica/
    end

    def start_game?
      text =~ /\w+/
    end
    
    def start
      send_message('¡Te doy la bienvenida a EgyptianScape!')
      kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['Chico', 'Chica'], one_time_keyboard: true)
      send_message("¿Eres un chico o una chica?", kb)
      user.reset_next_bot_command
      user.set_next_bot_command('GameMaster::Start')    
    end
    
    def gender
      @hero.genero = text
      kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      send_message("Introduce tu nombre:", kb)
      user.reset_next_bot_command
      user.set_next_bot_command('GameMaster::Start')  
    end
    
    def start_game
      user.reset_next_bot_command
      @hero.nametag = text
      kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['Comenzar'], one_time_keyboard: true)
      send_message("Buena suerte #{@hero.nametag}")
      send_message("¿Quieres comenzar?", kb)
      user.set_next_bot_command('GameMaster::Game')
    end
    
  end

  #################

  class Game < Base

    include RubyplayFramework

    def start?
      text =~ /Comenzar/
    end

    def playing?
      text =~ /Moverse|Investigar|\w+/
    end

    def try_restart?
      text =~ /\A\/restart/
    end

    def restarting?
      text =~ /Sí|Si|No/
    end

    def start
      p = MapPoint::Point.new(0, -10, -1)
      @hero.posicion = p
      @interprete.intialize_functions("app/assets/config/comandos.txt")
      @mapa.build_map("app/assets/config/pyramidMap.xml", "", "", "Cofre::CofreBuilder")
      p1 = MapPoint::Point.new(0, -10, 3)
      p2 = MapPoint::Point.new(0, -10, 4)
      @mapa.delete_adjacent(p1, p2)
      @mapa.add_entity(@hero.posicion, @hero)
      kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      send_message("Despiertas en un lugar desconocido. Parecen unas antiguas ruinas. No recuerdas como has acabado allí, pero algo te dice que estás en grave peligro. Busca una salida, rápido.")
      send_message("#{@mapa.map_nodes[@hero.posicion]}", kb)
      kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['Moverse', 'Investigar'], one_time_keyboard: true)
      send_message("¿Qué quieres hacer?", kb)
      user.reset_next_bot_command
      user.set_next_bot_command('GameMaster::Game')
    end

    def playing
      if(!@finPartida)
        if(text =~ /Moverse/)
          if(@hero.posicion == MapPoint::Point.new(-1,-11,1))
            kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['norte','sur','este','oeste','arriba','abajo', 'pasadizo'], 
            one_time_keyboard: true)
          else
            kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['norte','sur','este','oeste','arriba','abajo'], 
            one_time_keyboard: true)
          end
          send_message('¿En qué dirección?', kb)
        elsif(text =~ /Investigar/)
          #Cosas
        else
          success = try_interpreter
          if(success)
            kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['Moverse', 'Investigar'], one_time_keyboard: true)
            send_message("¿Qué quieres hacer?", kb)
          end
        end
        user.reset_next_bot_command
        user.set_next_bot_command('GameMaster::Game')
      else
        send_message("Enhorabuena, has logrado escapar")
        user.reset_next_bot_command
        user.set_next_bot_command('GameMaster::Start')
      end
    end

    ########## MOVIMIENTOS ###########
    
    def norte
      begin
        @mapa.move(@hero.posicion, @hero, 0, 0, 1)
        inicio = @hero.posicion
        nuevoPunto = MapPoint::Point.new(inicio.x(), inicio.y(), inicio.z()+1)
        @hero.posicion = nuevoPunto
        send_message("#{@mapa.map_nodes[@hero.posicion]}")
      rescue MapExceptions::NotAdjacentException
        send_message('El camino está bloqueado')
      end
    end

    def sur
      begin
        @mapa.move(@hero.posicion, @hero, 0, 0, -1)
        inicio = @hero.posicion
        nuevoPunto = MapPoint::Point.new(inicio.x(), inicio.y(), inicio.z()-1)
        @hero.posicion = nuevoPunto
        send_message("#{@mapa.map_nodes[@hero.posicion]}")
      rescue
        send_message('El camino está bloqueado')
      end
    end

    def este
      begin
        @mapa.move(@hero.posicion, @hero, 1)
        inicio = @hero.posicion
        nuevoPunto = MapPoint::Point.new(inicio.x()+1, inicio.y(), inicio.z())
        @hero.posicion = nuevoPunto
        send_message("#{@mapa.map_nodes[@hero.posicion]}")
      rescue
        send_message('El camino está bloqueado')
      end
    end

    def oeste
      begin
        @mapa.move(@hero.posicion, @hero, -1)
        inicio = @hero.posicion
        nuevoPunto = MapPoint::Point.new(inicio.x()-1, inicio.y(), inicio.z())
        @hero.posicion = nuevoPunto
        send_message("#{@mapa.map_nodes[@hero.posicion]}")
      rescue
        send_message('El camino está bloqueado')
      end
    end

    def arriba
      begin
        @mapa.move(@hero.posicion, @hero, 0, 1)
        inicio = @hero.posicion
        nuevoPunto = MapPoint::Point.new(inicio.x(), inicio.y()+1, inicio.z())
        @hero.posicion = nuevoPunto
        send_message("#{@mapa.map_nodes[@hero.posicion]}")
      rescue
        send_message('El camino está bloqueado')
      end
    end

    def abajo
      begin
        @mapa.move(@hero.posicion, @hero, 0, -1)
        inicio = @hero.posicion
        nuevoPunto = MapPoint::Point.new(inicio.x(), inicio.y()-1, inicio.z())
        @@hero.posicion = nuevoPunto
        send_message("#{@mapa.map_nodes[@hero.posicion]}")
      rescue
        send_message('El camino está bloqueado')
      end
    end

    def pasadizo
      begin
        @mapa.move(@hero.posicion, @hero, 1, 0, 1)
        inicio = @hero.posicion
        nuevoPunto = MapPoint::Point.new(inicio.x()+1, inicio.y(), inicio.z()+1)
        @hero.posicion = nuevoPunto
        send_message("#{@mapa.map_nodes[@hero.posicion]}")
      rescue
        send_message('La teletransportación no está permitida en este caso')
      end
    end

    ######## FIN MOVIMIENTOS ########

    def try_interpreter
      begin
        @interprete.parse(self, text)
        return true
      rescue RuntimeError
        send_message("Esa acción no está disponible")
        return false
      end
    end  

    def try_restart
      kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['Sí', 'No'], one_time_keyboard: true)
      send_message("¿Estás seguro?", kb)
      user.reset_next_bot_command
      user.set_next_bot_command('GameMaster::Game')
    end
    
    def restarting
      kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      if(text =~ /Si|Sí/)
        send_message("Reinicio del juego completado. Escribe /start para comenzar", kb)
        user.reset_next_bot_command
        user.set_next_bot_command('GameMaster::Start')  
      else
        send_message("Reinicio cancelado", kb)
      end
    end

  end

  ######################
  class Undefined < Base
    def start
      send_message('Comando desconocido. Asegurese de introducir el comando correcto')
    end
  end
end