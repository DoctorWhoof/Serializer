Namespace test2

#Import "../serializer"

'IMPORTANT! Always set the reflection filters for the desired namespaces
#Reflect test2..
#Reflect std..

Public
Function Main()
	
	Local t := New Test
	For Local d := Eachin Variant( t ).Type.GetDecls()
		Print "~t" + d
	Next
	
	Local json := New JsonObject()
	json.Serialize( "text","Just a little text" )
	json.Serialize( "number", 100.0 )
	json.Serialize( "isItTrue?", False )
	json.Serialize( "Knight1", New Knight )
	json.Serialize( "Knight2", New AnotherKnight )
	json.Serialize( "KnightStruct", New NonsenseStruct )
	Print json.ToJson()
	
	Knight.all.Clear()
	
	
	json.Deserialize()
	
End

Class Test
	
	Field a:Int
	Field b:String
	
	Method Show()
		Print a + b
	End	
	
End


'***************** Test classes and structs *****************

Class Knight
	
	Global all:= New Stack<Knight>
	
	Protected
	Field _name := "Ni!"
	Field _health:Float = 1000.0
	Field _schroob:= New Schruberry
	Field _nonsense:= New NonsenseStruct
	Field _color := New Color( 0, 0, 1, 1 )
	Field _position := New Vec3f( 5, 0, 1 )
	Field _style := FightStyle.Legless
	
	Public
	Method New()
		all.Add( Self )
		Print "New Knight!"
	End
	
	Property Health:Float()
		Return _health
	Setter( v:Float )
		_health = v
	End
	
	Property Name:String()
		Return _name
	Setter( n:String )
		_name = n
	End
	
	Property Request:Schruberry()
		Return _schroob
	Setter( s:Schruberry )
		_schroob = s
	End
	
	Property BrandNewName:NonsenseStruct()
		Return _nonsense
	Setter( n:NonsenseStruct )
		_nonsense = n
	End
	
	Property Position:Double[]()
		Return _position.ToArray()
	Setter( p:Double[] )
		_position.FromArray( p )
	End
	
	Property Color:Color()
		Return _color
	Setter( c:Color )
		_color = c
	End
	
	Property Style:FightStyle()
		Return _style
	Setter( f:FightStyle )
		_style = f
	End
		
End


Class AnotherKnight Extends Knight
	
	Method New()
		Super.New()
		_name = "AnotherNi!"
	End
	
	Property Ni:String()
		Return "ninininininini"
	Setter( p:String )
	End
	
End


Class Schruberry
	Property Random:Float()
		Return Rnd()
	Setter( bogus:Float )
		'One that looks nice. And not too expensive.
	End
End


Struct NonsenseStruct
	Private
	Field _words:String
	
	Public
	Property Words:String()
		Return _words
	Setter( w:String )
		_words = w
	End
	
	Method New()
		_words = "Ekke Ekke Ekke Ekke Ptang Zoo Boing!"
	End
	
	Method Serialize:JsonObject()
		Local obj:= New JsonObject
		obj.SetString("Class", Typeof( Self ).Name )
		obj.SetString("Words", Words )
		Return obj
	End
	
	Function Deserialize:NonsenseStruct( json:JsonValue )
		Local obj:= Cast<JsonObject>( json )
		Local ns := New NonsenseStruct
		ns.Words = obj["Words"].ToString()
		Return ns
	End	
	
End


Enum FightStyle
	Full,
	Armless,
	Legless
End
