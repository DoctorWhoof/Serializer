Namespace std.graphics

Struct Color Extension
	
	Method Serialize:JsonValue()
		Local arr := New Stack<JsonValue>
		arr.Push( New JsonNumber(R) )
		arr.Push( New JsonNumber(G) )
		arr.Push( New JsonNumber(B) )
		arr.Push( New JsonNumber(A) )
		Return New JsonArray( arr )
	End
	
	Function Deserialize:Color( json:JsonValue )
		Local arr := json.ToArray()
		Local c := New Color
		If arr
			If arr.Length = 4
				c.R = arr[0].ToNumber()
				c.G = arr[1].ToNumber()
				c.B = arr[2].ToNumber()
				c.A = arr[3].ToNumber()
			End
		End
		Return c
	End
	
	Method ToArray:Double[]()
		Return New Double[]( R, G, B, A )
	End
	
	Function FromArray:Color( arr:Double[] )
		Return New Color( arr[0], arr[1], arr[2], arr[3] )
	End
	
End
