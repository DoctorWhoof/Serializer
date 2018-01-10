Namespace std.Json

#Import "<std>"
#Import "<mojo>"
#Import "<reflection>"

#Import "source/input"
#Import "source/output"
#Import "source/variant_ext"

#Import "extensions/Color"
'#Import "extensions/Vec3f"

Using std..
Using mojo..

Global customArraySerializer:CustomArraySerializer

'**********************************************************************************

Class JsonValue Extension
	
	Method ToFloat:Float()
		Return Float( ToNumber() )
	End
	
	Method ToInt:Int()
		Return Int( ToNumber() )
	End
	
	Method ToUInt:UInt()
		Return UInt( ToNumber() )
	End
		
End

'**********************************************************************************

Class JsonObject Extension
	
	Public
	Method Serialize( key:String, v:Variant )
		
		Local value := JsonValueFromVariant( v )

		If value.IsNumber
			SetNumber( key, value.ToNumber() )
		Elseif value.IsString
			SetString( key, value.ToString() )
		Elseif value.IsBool
			SetBool( key, value.ToBool() )
		Elseif value.IsObject
			SetObject( key, value.ToObject() )
		ElseIf value.IsArray
			SetArray( key, value.ToArray() )
		End
	End
	
	
	Method Deserialize()
		If Not Empty
			For Local key := Eachin Self.ToObject().Keys
				LoadFromJsonObject( Self[ key ].ToObject(), Null, Null )
			Next
		End
	End
	
	
	Method Merge( json:JsonObject )
		Local otherMap := json.ToObject()
		
		For Local k := Eachin otherMap.Keys
			Local value := otherMap[ k ]
			If value.IsNumber
				SetNumber( k, value.ToNumber() )
			ElseIf value.IsString
				SetString( k, value.ToString() )
			ElseIf value.IsBool
				SetBool( k,  value.ToBool() )
			ElseIf value.IsObject
				SetObject( k, value.ToObject() )
			ElseIf value.IsArray
				SetArray( k, value.ToArray() )
			End
		Next
	End
	
	Private
	'Allows serialization without setting a key. For internal use only.
	Method Serialize( v:Variant )
		Local value := Cast<JsonObject>( JsonValueFromVariant( v ) )
		Merge( value )
	End
	
End

'**********************************************************************************

'This class needs to be implemented per app in order to provide support for object arrays. Need to find better solution in the future.
Class CustomArraySerializer Abstract

	Method Serialize:JsonArray( v:Variant ) Virtual
		Return Null	
	End

	Method Deserialize:Variant( jsonArr:Stack<JsonValue> ) Virtual
		Return Null
	End
	
End