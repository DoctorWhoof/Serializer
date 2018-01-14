Namespace std.Json

#Import "<std>"
#Import "<mojo>"
#Import "<reflection>"

Using std..
Using mojo..

'Simply creates the object, doesn't load any values into it
Function BasicDeserialize:Variant( obj:StringMap<JsonValue>, constructorArgTypes:TypeInfo = Null, arguments:Variant[] = Null )
	
	Local v:Variant
	
	If obj["Class"]
	 	Local objClass:= obj["Class"].ToString()
		Local info := TypeInfo.GetType( objClass )
		Local info_ext := TypeInfo.GetType( objClass + " Extension" )
		
		If info_ext
			If info_ext.GetDecl( "Deserialize" )
				Return CustomDeserialize( info_ext, New JsonObject( obj ), Null, Null )
			End
		End
		
		If info
			If info.GetDecl( "Deserialize" )
				Return CustomDeserialize( info, New JsonObject( obj ), Null, Null )
			End
			
			Local constructor := info.GetDecl( "New" )
			If constructor
				v = constructor.Invoke( Null, Null )
			Else
				If( Not arguments = Null ) And ( Not constructorArgTypes = Null )
					constructor = info.GetDecl( "New", constructorArgTypes )
					v = constructor.Invoke( Null, arguments )
				Else
					Print( "Deserialize: Error, Invalid constructor arguments type or arguments." )
					Print( "Class " + info.Name + " may need a custom Deserializer. These are the available declarations:" )
					For Local dec := Eachin info.GetDecls()
						Print "~t" + dec
					Next
				End
			End
		Else
			Print( "Deserialize: Class " + objClass + " not found." )
		End
		
	End
	
	If v = Null Then Print( "Deserialize: Nothing to return." )
	Return v
End


'Creates a new object, then loads its properties with optional filtering.
Function LoadFromJsonObject:Variant( obj:StringMap<JsonValue>, include:StringStack = Null, exclude:StringStack = Null )

	Local v := BasicDeserialize( obj )
	
	Local info:TypeInfo
	If v.Type.Kind = "Struct"
		info = v.Type
	Else
		info = v.DynamicType
	End
	
	Assert( info <> "Void", "Deserialize Error: Invalid Class (Hint: Is the required class source file properly reflected?~n" )
	
'	Print info
	If info.GetDecl( "Deserialize") Then Return v
	
	Local info_ext := TypeInfo.GetType( info.Name + " Extension")
	If info_ext
		If info_ext.GetDecl( "Deserialize") Then Return v
	End
	
	
	For Local key := Eachin obj.Keys
		If key = "Class" Continue

		If include
			If Not include.Empty
				If Not include.Contains( key ) Continue	
			End
		End
		
		If exclude
			If Not exclude.Empty
				If exclude.Contains( key ) Continue
			End
		End
		
		'Check for custom deserializer
		Local d:= FindDecl( key, info )
		Assert( d, "~nDeserializer: Can't find declaration name '" + key + "'. Ensure custom deserializer is working properly.")
		
		If d.Type.Kind = "Class" Or d.Type.Kind = "Struct"		
			Local d_ext := TypeInfo.GetType( d.Type.Name + " Extension" )
			If d_ext
				If d_ext.GetDecl( "Deserialize" )
					CustomDeserialize( d_ext, obj[key], d, v  )
					Continue
				End
			End
			
			If d.Type.GetDecl( "Deserialize" )
				CustomDeserialize( d.Type, obj[key], d, v )
				Continue
			End
		End
		
		'If no custom serialization found, Applies value
		Local value := LoadFromJsonValue( v, obj[key], d )

	Next
	
	Return v

End


Function CustomDeserialize:Variant( type:TypeInfo, json:JsonValue, d:DeclInfo, owner:Variant )
	Local v:Variant
	Local deserialize := type.GetDecl( "Deserialize" )

	If deserialize
		v = deserialize.Invoke( Null, New Variant[]( Variant (json) ) )
	End
	
	If Not v Then Print ("Serializer: Custom deserializer fail, nothing to return.")
	If( d And v )Then d.Set( owner, v )

	Return v
End


Function FindDecl:DeclInfo( name:String, type:TypeInfo )
	Local d:DeclInfo
	
	Local type_ext := TypeInfo.GetType( type.Name + " Extension" )
	If type_ext
		d = type_ext.GetDecl( name )	
	End
	If Not d
		d = type.GetDecl( name )
		If Not d
			If type.SuperType
				If Not d
					d = FindDecl( name, type.SuperType )
				End
			Else
				Return Null	
			End
		End
	End
	
	Return d
End


'Use this if the target object has already been created, and all you want is to load its properties
Function GetPropertiesFromJsonObject( target:Variant, json:JsonObject, include:StringStack = Null, exclude:StringStack = Null )

	json.GetValue( "Name" ).ToString()
	For Local d := Eachin target.DynamicType.GetDecls()
		
		If include
			If Not include.Empty
				If Not include.Contains( d.Name ) Continue	
			End
		End
		If exclude
			If Not exclude.Empty
				If exclude.Contains( d.Name ) Continue
			End
		End
		If ( d.Kind = "Property" And d.Settable ) Or ( d.Kind = "Field" And Not d.Name.StartsWith("_") )
			Local value := LoadFromJsonValue( target, json.GetValue( d.Name ), d )
'			Print( d.Name + " = " + VariantToString( value ) )
		End
		
	Next
End


'loads a single value into an existing object.
'Function LoadFromJsonValue:Variant( v:Variant, valueName:String, jsonValue:JsonValue )
'	Local info := v.DynamicType
'	Local d:= info.GetDecl( valueName )
'	Local value := LoadFromJsonValue( v, jsonValue, d )
'	Return v
'End


'Our main workhorse, recursively loads a properly cast JasonValue into an object's Declaration.
Function LoadFromJsonValue:Variant( v:Variant, value:JsonValue, d:DeclInfo )	
	Local newVar:Variant
	If Not value Return Null
	
	'Special case for Enums
	If d
		If d.Type.Kind = "Enum"
			newVar = Variant( d.Type.MakeEnum( value.ToInt() ) )
			d.Set( v,newVar )
			Return newVar
		End
	End
	
	'Everything else...
	If value.IsNumber	
		newVar = Variant( value.ToNumber() )
		If d And v
			Local properV :Variant
			Select d.Type.Name
			Case "Float"
				properV = Variant( Float( value.ToNumber() ) )
			Case "Double"
				properV = Variant( Double( value.ToNumber() ) )
			Case "Int"
				properV = Variant( Int( value.ToNumber() ) )
			Case "UInt"
				properV = Variant( UInt( value.ToNumber() ) )
			End
			d.Set( v, properV )
		End
	ElseIf value.IsString
		newVar = Variant( value.ToString() )
		If d And v Then d.Set( v, newVar )
	ElseIf value.IsBool
		newVar = Variant( value.ToBool() )
		If d And v Then d.Set( v, newVar )
	Elseif value.IsObject
		newVar = LoadFromJsonObject( value.ToObject() )
		If d And v Then d.Set( v, newVar )
	ElseIf value.IsArray
		Local jsonArr := value.ToArray()
		If Not jsonArr.Empty
			Local first := jsonArr[0]
			
			If first.IsNumber
				newVar = DeserializeArray<Double>( jsonArr )
			Elseif first.IsString
				newVar = DeserializeArray<String>( jsonArr )
			Elseif first.IsBool
				newVar = DeserializeArray<Bool>( jsonArr )
			Elseif first.IsObject
				'To use object arrays, implement a class that extends CustomArraySerializer and returns the properly typed variant array in its Deserialize() method.
				'i,e.: Return DeserializeArray<game3d.Component>( jsonArr )
				'Then add an instance of that class into the customArrayObject field.
				Assert( customArraySerializer, "Deserialize Error: Array Type needs special 'CustomArray' object to deserialize" )
				newVar = customArraySerializer.Deserialize( jsonArr )
			End
			
			If d And v Then d.Set( v, newVar )
		End
	End
	
	Return newVar
End


'Array helper
Function DeserializeArray<T>:Variant( jsonArr:Stack<JsonValue> )
	Local arr := New T[ jsonArr.Length ]
	For Local n := 0 Until jsonArr.Length
		Local value:= LoadFromJsonValue( Null, jsonArr[n], Null )
		arr[ n ] = Cast<T>( value )
	Next
	Return Variant( arr )
End

