Namespace std.geom

Struct Vec3f Extension

'	Method Serialize:JsonValue()
'		Local arr := New Stack<JsonValue>
'		arr.Push( New JsonNumber(X) )
'		arr.Push( New JsonNumber(Y) )
'		arr.Push( New JsonNumber(Z) )
'		Return New JsonArray( arr )
'	End
	
	Method ToArray:Double[]()
		Return New Double[]( X, Y, Z )
	End
	
	Method FromArray( arr:Double[] )
		If arr
			X = arr[0]
			Y = arr[1]
			Z = arr[2]
		End
	End
	
End
