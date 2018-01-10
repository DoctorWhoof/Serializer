Namespace std.Json

#Import "<std>"
#Import "<mojo>"
#Import "<reflection>"

Using std..
Using mojo..

'Extracts JsonValue value from a variant, recursive for arrays and objects
Function JsonValueFromVariant:JsonValue( v:Variant )
	Local newValue:JsonValue
	Local info:= v.Type

	If info.Kind.StartsWith( "Unknown" )
		Print( "Warning: Property cannot be reflected and can't be serialized." )
	Elseif info.Kind = "Array"
		Select info.Name
		Case "Float[]"
			newValue = New JsonArray( GetJsonStack<JsonNumber,Float>( v ) )
		Case "Double[]"
			newValue = New JsonArray( GetJsonStack<JsonNumber,Double>( v ) )
		Case "Int[]"
			newValue = New JsonArray( GetJsonStack<JsonNumber,Int>( v ) )
		Case "UInt[]"
			newValue = New JsonArray( GetJsonStack<JsonNumber,UInt>( v ) )
		Case "String[]"
			newValue = New JsonArray( GetJsonStack<JsonString,String>( v ) )
		Case "Bool[]"
			newValue = New JsonArray( GetJsonStack<JsonBool,Bool>( v ) )
		Default
			Assert( customArraySerializer, "Serialize Error: Array Type needs special 'CustomArraySerializer' object to serialize" )
			newValue = customArraySerializer.Serialize( v )
		End
	Else
		Select info.Name
		Case "Float"
			newValue = New JsonNumber( Cast<Float>( v ) )
		Case "Double"
			newValue = New JsonNumber( Cast<Double>( v ) )
		Case "Int"
			newValue = New JsonNumber( Cast<Int>( v ) )
		Case "UInt"
			newValue = New JsonNumber( Cast<UInt>( v ) )
		Case "String"
			newValue = New JsonString( Cast<String>( v ) )
		Case "Bool"
			newValue = New JsonBool( Cast<Bool>( v ) )
		Default
			Local obj := New JsonObject
			Local customSerialize := False
			
			If info.Kind="Class" Or info.Kind="Interface"	'If a value is returned by the function SerializeClass, it means a "Serialize()" method was found and returned a JsonValue
				
				Local dynamicValue := SerializeClass( v.DynamicType, v, obj )
				If dynamicValue Then Return dynamicValue
				
				Return obj
				
			Elseif info.Kind = "Struct"
				
				Local structValue := SerializeClass( v.Type, v, obj )
				If structValue Then Return structValue
				
				Return obj
				
			Elseif info.Kind = "Enum"
				
				newValue = New JsonNumber( v.EnumValue )
				
			Else
				
				newValue = New JsonString( "Serializer: Warning, unhandled scenario found!" )
				
			End
			
		End
	End

	Return newValue
End


Function SerializeClass:JsonValue( c:TypeInfo, v:Variant, obj:JsonObject )

	Local json:JsonValue

	'Gets superclass decls first. Recursive.
	If c.SuperType
		json = SerializeClass( c.SuperType, v, obj )
	End
	
	'Search for class extensions and custom Serialize() methods
	Local s := c.GetDecl( "Serialize" )
	If s
		json = Cast<JsonValue>( s.Invoke( v, Null ) )
	Else
		Local  c_ext := TypeInfo.GetType( c.Name + " Extension" )	'hmmm, this one should be called first, shouldn't it?
		If c_ext
			Local s_ext := c_ext.GetDecl( "Serialize" )
			If s_ext
				json = Cast<JsonValue>( s_ext.Invoke( v, Null ) )
			Else
				obj.Merge( SerializeDecls( c_ext, v ) )
			End
		End	
	End
	
	'If nothing was returned by now, no custom serializer was found and we simply merge obj with the current declarations and return null
	If json
		Return json
	Else
		obj.Merge( SerializeDecls( c, v ) )
	End
	Return Null
End


'Iterates and serializes each of an object's Properties and fields
Function SerializeDecls:JsonObject( type:TypeInfo, instance:Variant )
	Local obj:= New JsonObject
	obj.SetString( "Class", type.Name )
	
	Assert( type.Name <> "Void", "~nSerialize Error: Class not reflectable.~nMake sure you include all necessary namespaces using #Reflect filters~n")
	
	For Local decl:DeclInfo = Eachin type.GetDecls()
		If ( decl.Kind = "Property" And decl.Settable ) Or ( decl.Kind = "Field" And Not decl.Name.StartsWith("_") )
			If decl.Type.Name.StartsWith("Unknown")
				Print( "Serializer: Property " + decl.Name + " is not reflected and can't be serialized. Use #Reflect filters on all desired namespaces." )
			Else
				obj.Serialize( decl.Name, decl.Get( instance ) )
'				Print( decl.Name + "=" + VariantToString( decl.Get( instance ) ) )
			End
		End
	Next
	Return obj
End


'Array helper
Function GetJsonStack<T,V>:Stack<JsonValue>( v:Variant )
	Assert( ( v.Type.Kind = "Array" ), "GetJsonStack: Variant " + v.Type.Name + " is not an array" )
	Local stack := New Stack<JsonValue>
	Local arr := Cast<V[]>( v )
	For Local element := Eachin arr
		stack.Push( JsonValueFromVariant( element ) )
	Next
	Return stack
End

