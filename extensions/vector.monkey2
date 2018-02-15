Namespace std.geom


Struct Vec2<T> Extension
	
	Method ToArray:T[]()
		Return New T[]( X, Y )
	End
	
	Function FromArray:Vec2<T>( arr:T[] )
		Return New Vec2<T>( arr[0], arr[1] )
	End
	
End


Struct Vec3<T> Extension
	
'	Method ToArray:T[]()
'		Return New T[]( X, Y, Z )
'	End
	
	Method ToArray:Double[]()				'I need this to return double for consistency.
		Return New Double[]( X, Y, Z )
	End
	
	Function FromArray:Vec3<T>( arr:T[] )
		Return New Vec3<T>( arr[0], arr[1], arr[2] )
	End
	
	
End

Struct Vec4<T> Extension
	
	Method ToArray:T[]()
		Return New T[]( X, Y, Z, W )
	End
	
	Function FromArray:Vec4<T>( arr:T[] )
		Return New Vec4<T>( arr[0], arr[1], arr[2], arr[3] )
	End
	
End