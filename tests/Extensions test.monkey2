Namespace test2

#Import "../serializer"

'IMPORTANT! Always set the reflection filters for the desired namespaces
#Reflect test2..
#Reflect std..

Public
Function Main()
	
	'Serialize objects to json object
	Local json := New JsonObject()
	
	Local obj0 := New Peasant
	
	Local obj1 := New Knight
	obj1.height = Height.Giant
	obj1.color = Color.Blue
	
	Local obj2 := New King
	obj2.height = Height.Dwarf
	obj2.color = Color.Orange
	
	Local obj3 := New Bishop
	obj3.height = Height.Normal
	obj3.color = Color.Red
	
	json.Serialize( "obj0", obj0 )
	json.Serialize( "obj1", obj1 )
	json.Serialize( "obj2", obj2 )
	json.Serialize( "obj3", obj3 )
	
	Print "Serialization results:~n"
	Print json.ToJson()
	
	'Clear all objects
	
	Peasant.all.Clear()
	
	'Deserialize from json object
	
	json.Deserialize()
	json = New JsonObject()
	
	'Serialize again to check if it matches first time!
	Local n := 0
	For Local obj := Eachin Peasant.all
		json.Serialize( "obj" + n, obj )
		n += 1
	Next
	
	Print "~nDeserialization results (Should always match!):~n"
	Print json.ToJson()
	
End

'***************** Test classes and structs *****************


Class Peasant
	Global all:= New Stack<Peasant>
	
	Field color:= Color.White
	Field height:= Height.Little
	
	Protected
	Field _name := "Dudley"
	Field _health:Float = 100.0

	Public
	Method New()
		all.Add( Self )
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
End


Class Knight Extends Peasant
	Protected
	Field _title := "Ni!"
	Field _wealth:Float = 1000.0
	
	Public
	Method New()
		Super.New()
		_name = "Sir Dude"	
	End
	
	Property Wealth:Float()
		Return _wealth
	Setter( v:Float )
		_wealth = v
	End
	
	Property Title:String()
		Return _title
	Setter( n:String )
		_title = n
	End
End


Class King Extends Knight

	Method New()
		Super.New()
		_name = "King Dude"	
	End

End


Class Bishop Extends King
	
	Method New()
		Super.New()
		_name = "Bishop Brown"	
	End
	
End


Enum Height
	Dwarf,
	Little,
	Normal,
	Tall,
	Giant
End

'******************************** Extensions '********************************

Class Peasant Extension

	Property Info:String()
		Return "Name: " + _name + ", Health: " + _health
	Setter( t:String )
		
	End	
	
End


Class Bishop Extension
	
	'"First level" objects (the first ones to be deserialized ) ALWAYS need to return a JsonObject with their class name to be properly identified.
	Method Serialize:JsonValue()
		Local obj:= New JsonObject
		obj.SetString("Class", InstanceType.Name )
		'Once you have the class name, anything else is fair game!
		obj.SetString("CatchPhrase","I'm the bishop LOL!")
		Return obj
	End
	
	Function Deserialize:Bishop( json:JsonValue )
		Local obj:= json.ToObject()
		'Get your stuff from obj here...
		Return New Bishop
	End	

End


