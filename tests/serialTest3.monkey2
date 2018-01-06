Namespace test2

#Import "../serializer"

'IMPORTANT! Always set the reflection filters for the desired namespaces
#Reflect test2..

Public
Function Main()
	Local json := New JsonObject()
	json.Serialize( "Knight1", New Knight )
	json.Serialize( "Knight2", New Peasant )
	Print json.ToJson()
End

'***************** Test classes and structs *****************

Class Knight
	Protected
	Field _name := "Ni!"
	Field _health:Float = 1000.0
	
	Public
	Method New()
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


Class Peasant
	Protected
	Field _name := "Dudley"
	Field _health:Float = 100.0
	
	Public
	Method New()
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
