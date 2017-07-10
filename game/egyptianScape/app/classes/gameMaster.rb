require 'telegram/bot'
require 'rubyplay_framework'
require 'heroe'
require 'cofre'
require 'npc'

module GameMaster

  class Base
    include RubyplayFramework

    attr_accessor :user, :message
    attr_reader :api, :hero

    def initialize(user, message, hero)
      @user = user
      @message = message
      token = Rails.application.secrets.bot_token
      @api = ::Telegram::Bot::Api.new(token)
      @hero = hero
      @npc = nil
      @cofre = nil
      @mapa = init_Map()
      @interprete = init_Interpreter()
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
      text =~ /Moverse|Investigar|Mochila|\w+/
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
      p = MapPoint::Point.new(0, -10, 1)
      @npc = Npc.new("NPC", "Extraño encapuchado", p)
      @cofre = Cofre::Cofre.new("Cofre", "Vitrina en un pedestal de piedra")
      @interprete.intialize_functions("app/assets/config/comandos.txt")

      @mapa.build_map("app/assets/config/pyramidMap.xml", "", "", "Cofre::CofreBuilder")
      p1 = MapPoint::Point.new(0, -10, 3)
      p2 = MapPoint::Point.new(0, -10, 4)
      @mapa.delete_adjacent(p1, p2)
      @mapa.add_entity(@hero.posicion, @hero)
      @mapa.add_entity(@npc.posicion, @npc)

      kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      send_message("Despiertas en un lugar desconocido. Parecen unas antiguas ruinas. No recuerdas como has acabado allí, pero algo te dice que estás en grave peligro. Busca una salida, rápido.")
      send_message("#{@mapa.map_nodes[@hero.posicion]}", kb)
      kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['Moverse', 'Investigar', 'Mochila'], one_time_keyboard: true)
      send_message("¿Qué quieres hacer?", kb)
      user.reset_next_bot_command
      user.set_next_bot_command('GameMaster::Game')
    end

    def playing
      
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
          aux = []
          @mapa.map_nodes[@hero.posicion].each_entity do |entity|
            if(entity!=@hero)
              aux << entity
            end
          end
          if(aux.length > 0)
            send_message('Mirando detenidamente alcanzas a ver:')
            aux.each { |entity| send_message(entity.nametag) }
            if(aux.find { |entity| entity.type == "NPC"})
              if((@hero.mochila != nil) && (@hero.mochila[0] == "Libro de Thoth") && (@hero.posicion == MapPoint::Point.new(0,-10,-1)))
                kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['hablar','ritual'], one_time_keyboard: true)
                send_message("¿Qué quieres hacer?", kb)
              else
                kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['hablar'], one_time_keyboard: true)
                send_message('¿Qué quieres hacer?', kb)
              end
            elsif(aux.find { |entity| entity.type == "Cofre"})
              kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['abrir'], one_time_keyboard: true)
              send_message('¿Qué quieres hacer?', kb)
            else
              kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['abrir','hablar'], one_time_keyboard: true)
              send_message('¿Qué quieres hacer?', kb)
            end
          else
            send_message('No hay nada interesante')
            kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['Moverse','Investigar', 'Mochila'], one_time_keyboard: true)
            send_message("¿Qué quieres hacer?", kb)
          end
        elsif(text =~ /Mochila/)
          if(@hero.mochila != nil && !@hero.mochila.empty?)
            send_message('En la mochila tienes lo siguiente:')
            @hero.mochila.each { |item| send_message(item) }
            kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['Moverse','Investigar','Mochila'], one_time_keyboard: true)
            send_message("¿Qué quieres hacer?", kb)
          else
            send_message('La mochila está vacía')
            kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['Moverse','Investigar','Mochila'], one_time_keyboard: true)
            send_message("¿Qué quieres hacer?", kb)
          end
        else
          success = try_interpreter
          if(success)
            if(@hero.posicion == MapPoint::Point.new(0,-10,4))
              kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
              send_message("Enhorabuena, has logrado escapar. Escribe /start para volver a empezar.", kb)
              user.reset_next_bot_command
              user.set_next_bot_command('GameMaster::Start')
            else
              kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['Moverse','Investigar','Mochila'], one_time_keyboard: true)
              send_message("¿Qué quieres hacer?", kb)
              user.reset_next_bot_command
              user.set_next_bot_command('GameMaster::Game')
            end
          end
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
        @hero.posicion = nuevoPunto
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
    
    ####### INTERACCIONES #######
    
    def abrir
      @hero.mochila = ["Libro de Thoth"]
      p = MapPoint::Point.new(0, -10, -1)
      @mapa.add_entity(p, @npc)
      p = MapPoint::Point.new(0, -10, 1)
      @mapa.remove_entity(p, @npc)
      send_message('Has obtenido el Libro de Thoth')
      @mapa.remove_entity(@hero.posicion, @cofre)
      p = MapPoint::Point.new(-1, -11, 1)
      @mapa.delete_adjacent(@hero.posicion, p)
      send_message('El pasadizo por el que has llegado se ha cerrado, pero la puerta oeste se ha abierto.')
      p = MapPoint::Point.new(-1, -11, 2)
      @mapa.add_new_adjacent(@hero.posicion, p)
    end
    
    def hablar
      if(@hero.mochila != nil && @hero.mochila[0] == "Libro de Thoth")
        send_message(@npc.hablar2)
      else
        send_message(@npc.hablar1(@hero.genero))
      end
    end

    def ritual
      @mapa.remove_entity(@hero.posicion, @npc)
      @hero.mochila.shift
      p1 = MapPoint::Point.new(0, -10, 3)
      p2 = MapPoint::Point.new(0, -10, 4)
      @mapa.add_new_adjacent(p1, p2)
      send_message('Un temblor. Parece que se ha abierto algo en alguna parte')
    end
    
    #############################
    
    ######## Interprete ########
    def try_interpreter
      begin
        @interprete.parse(self, text)
        return true
      rescue RuntimeError
        send_message("Esa acción no está disponible")
        return false
      end
    end 
    ########################### 

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