# Rubyplay

Una librería para facilitar el desarrollo de juegos de rol para interfaces de texto.

[![Gem Version](https://badge.fury.io/rb/rubyplay_framework.svg)](https://badge.fury.io/rb/rubyplay_framework)

## Instalación

Añade lo siguiente a tu Gemfile:

```ruby
gem 'rubyplay_framework', '~> 1.6', '>= 1.6.4'
```

Y ejecuta:

```shell
$ bundle
```

O haz una instalación en el sistema:

```shell
$ gem install rubyplay_framework
```
## Empleo

### Generando mapas

La librería permite cargar mapas para juegos utilizando simplemente un fichero XML con toda la información necesaria. Se recomienda validar dicho [XML](https://www.w3schools.com/xml/) contra el [XSD](https://www.w3schools.com/xml/schema_intro.asp) que se incluye junto con la librería (lib/map.xsd). La validación te permitirá saber si tu XML va a generar un mapa correctamente o, por el contrario, si acabará produciendo un error (si lo que te interesa es saber como extender el XSD para que el mapa se construya con tus propios objetos salta a la sección Extendiendo mapas).

Un ejemplo muy sencillo de fichero XML válido sería: 

```xml
<?xml version="1.0" encoding="UTF-8"?>
<map xmlns="http://www.w3schools.com/map.xsd"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://www.w3schools.com/map.xsd ../lib/map.xsd">
	<node>
		<point>
			<x>0</x>
			<y>0</y>
			<z>0</z>
		</point>
		<dungeon>
			<name>Tomb</name>
			<description>A small room with many coffins</description>
			<entity>
				<type>Hero</type>
				<nametag>Keops</nametag>
			</entity>
		</dungeon>
		<adjacent>
			<point>
				<x>1</x>
				<y>0</y>
				<z>0</z>
			</point>
		</adjacent>
	</node>
	<node>
		<point>
			<x>1</x>
			<y>0</y>
			<z>0</z>
		</point>
		<dungeon>
			<name>Treasure room</name>
			<description>A dark room filled with golden treasures</description>
		</dungeon>
		<adjacent>
			<point>
				<x>0</x>
				<y>0</y>
				<z>0</z>
			</point>
		</adjacent>
	</node>
</map>
```

A continuación, se muestra como generar el mapa:

```ruby
require 'rubyplay_framework'

map = init_Map()
map.build_map("myMap.xml")
```
Cabe destacar que el constructor del mapa `build_map(filePath)`espera recibir un mapa completamente conexo. Si en el fichero XML existe algún nodo que no presente ninguna adyacencia la construcción del mapa fallará.

### Intérprete

La librería proporciona un sencillo intérprete de mandatos cuya finalidad es ejecutar las funciones correspondientes a los mandatos introducidos por los usuarios.
Su funcionamiento es sencillo, se debe proporcionar un fichero con un listado de las funciones disponibles. Dicho fichero será utilizado por el parser para comprobar la correspondencia de la entrada recibida con alguna de las funciones listadas en el fichero. Si una función admite parámetros en el fichero se debe escribir el nombre de la función seguido de tantos parámetros como admita, separados por espacios (no importa el nombre que se dé a los parámetros):

```txt
sumar x y
sayHello
```
A continuación, se muestra cómo utilizar el intérprete:

```ruby
require 'rubyplay_framework'

interprete = init_Interpreter()
interprete.intialize_functions("myFile.txt")
someObject = SomeObject.new()
result = interprete.parse(someObject, "sumar -1 2")
```
En caso de que se vaya a ejecutar una función que devuelva un resultado conviene igualarlo a una variable para almacenarlo. Puesto que la ejecución de la función se realiza mediante una llamada dinámica a un método de un objeto es necesario indicar el objeto cuya función se va a ejecutar (en este caso sumar de SomeObject). En caso de que en SomeObject esté definido el método sumar que recibe dos parámetros se ejecutará dicha suma.

## Extendiendo la librería

### Extendiendo mapas

En caso de querer ampliar el contenido del mapa es preciso realizar todos los pasos que se describen a continuación:

1. Para generar un mapa extendido se recomienda extender el XSD proporcionado de la siguiente manera:
   
   1.1. El XSD consta de tres tipos definidos: pointType, entityType y dungeonType
	Para extender dichos tipos predefinidos es necesario hacer import del XSD en el que se definen de la siguiente manera:
	
		<xs:schema targetNamespace="http://www.w3schools.com/mapExtended.xsd"
		elementFormDefault="qualified"
		xmlns="http://www.w3schools.com/mapExtended.xsd"
		xmlns:map="http://www.w3schools.com/map.xsd"
		xmlns:xs="http://www.w3.org/2001/XMLSchema">
    
		<xs:import namespace="http://www.w3schools.com/map.xsd" schemaLocation="../lib/map.xsd"/>
		
	Como se puede ver, se debe establecer un namespace concreto para los elementos del XSD que se van a extender.
	También se debe incluir la etiqueta import con el namespace y la localización del esquema a extender.
		
	1.2. Una vez importado el XSD original, podremos extender los tipos que se importan del mismo.
		pointType y dungeonType se deben extender definiendo un nuevo tipo complejo en el que se extiendan los tipos importados
		de la siguiente manera (etiqueta <extension>):
			
			<xs:complexType name="pointTypeExtended">
				<xs:complexContent>
					<xs:extension base="map:pointType">
						<xs:sequence>
							<xs:element name="w" type="xs:integer"/>
						</xs:sequence>
					</xs:extension>
				</xs:complexContent>
			</xs:complexType>

			<xs:complexType name="dungeonTypeExtended">
				<xs:complexContent>
					<xs:extension base="map:dungeonType">
						<xs:sequence>
							<xs:element name="lvl" type="xs:integer"/>
						</xs:sequence>
					</xs:extension>
				</xs:complexContent>
			</xs:complexType>
			
		En el caso de entityType no es necesario extender el tipo porque entityType admite <any> elemento después de nametag.
		En este caso, con poner cualquier nuevo elemento en el XML el XSD nos lo dará como bueno.
		
	1.3. Por último, se debe calcar la estructura que se define en el XSD original, pues el orden de aparición y número de los elementos es importante para que el mapa se construya correctamente:
		
		<xs:element name="map">
		  <xs:complexType>
			<xs:sequence>
				<xs:element name="node" minOccurs="2" maxOccurs="unbounded">
				  <xs:complexType>
					<xs:sequence>
						<xs:element name="point" type="pointTypeExtended" minOccurs="1" maxOccurs="1"/>
						<xs:element name="dungeon" type="dungeonTypeExtended" minOccurs="1" maxOccurs="1"/>
						<xs:element name="adjacent" minOccurs="1" maxOccurs="1">
							<xs:complexType>
								<xs:sequence>
									<xs:element name="point" type="pointTypeExtended" minOccurs="1" maxOccurs="unbounded"/>
								</xs:sequence>
							</xs:complexType>
						</xs:element>
					</xs:sequence>
				  </xs:complexType>
				</xs:element>
			</xs:sequence>
		  </xs:complexType>
		</xs:element>

	Todo se deja prácticamente igual, con la salvedad de que en los elementos point utilizamos el nuevo tipo extendido, 
	al igual que en el elemento dungeon.
		
	1.4. Finalmente, en el XML se debe definir el namespace que se utiliza en el esquema extendido:

		<map xmlns="http://www.w3schools.com/mapExtended.xsd"
		 xmlns:map="http://www.w3schools.com/map.xsd"
		 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		 xsi:schemaLocation="http://www.w3schools.com/mapExtended.xsd ./mapExtended.xsd">

    La definición del namespace se realiza junto con la referencia al esquema. Ahora, cada vez que usemos un elemento original del XSD que se ha extendido se debe utilizar el namespace map.
		
2. Se deben extender tanto las clases Point, Dungeon y Entity (en función de cuál de los tres elementos se extienda) así como
   las clases builder de cada uno.
	
	 En el caso de las clases normales es importante redefinir el constructor (llamando a super para los atributos que son heredados de la clase padre) y hacer un attr_accesor de los nuevos atributos. En la clase builder se debe crear un nuevo método constructor creando un objeto de la nueva clase normal extendida y se debe redefinir el método build_xxxx() para que admita los nuevos atributos. 
	 En el caso de dungeon se debe situar los nuevos atributos antes de los atributos de la clase padre que tienen valores por defecto.
	 Ejemplo: 
		
```ruby
		class PointExtended < MapPoint::Point
		  def initialize(x = 0, y = 0, z = 0, w = 0)
			super(x,y,z)
			@w = w
		  end
		  
		  attr_accessor :w
		  
		  def to_s()
			"(#{@x},#{@y},#{@z},#{@w})"
		  end
		  
		  protected
			def state
			  super << w
			end
		end

		class PointBuilderExtended < MapPoint::PointBuilder
		  def initialize()
			@point = PointExtended.new()
		  end
		  
		  attr_reader :point
		  
		  #Builds the point of a node
		  def build_point(x, y, z, w)
			super(x,y,z)
			add_w(w.to_i)
		  end
		  
		  def add_w(w)
			@point.w = w
		  end
		end
```
    
### Extender el intérprete

Para extender la funcionalidad del intérprete y hacerlo más genérico y flexible bastaría con tomar los ficheros gameLexer.rex y gameParser.racc incluidos en la librería. Estos ficheros se pueden modificar directamente para generar un lexer y un parser que trabajen en conjunto para formar el intérprete. El fichero gameLexer.rex emplea la sintaxis de [Rexical](https://github.com/tenderlove/rexical), mientras que gameParser.racc emplea la sintaxis de [Racc](https://github.com/tenderlove/racc).

Para general los nuevos .rb para el lexer y el parser basta con compilarlos de la siguiente manera por consola (es necesario tener ambas librerías):

```shell
$ rex lib/interpreter/gameLexer.rex -o lib/interpreter/gameLexer.rb
```
```shell
$ racc lib/interpreter/gameParser.racc -o lib/interpreter/gameParser.rb
```
