Namespace std.Json

'WIP. Unfinished. Not used yet.

Class SpecialCases
	
	Global classes := New String[]( "std.graphics.Color" )
	
	Function ToJson:JsonObject( v:Variant )
		Local json := New JsonObject
		json.Serialize( v )
	
		For Local d := Eachin InstanceType.GetDecls()
			If d.Kind = "Property" And d.Settable
				
				Select d.Type.Name
				Case "std.graphics.Color"
					Local c := Cast<Color>( d.Get( v ) )
					json.SetArray( d.Name, c.ToJsonArray() )
				End
				
			End
		End
		
		json.SetString( "Name", Name )
		Return json
	End
	
End