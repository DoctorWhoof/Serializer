Namespace test

#Import "<reflection>"
#Reflect test..

Function Main()
	
	Local c := New TestClass
	For Local d := Eachin Variant( c ).Type.GetDecls()
		Print "~t" + d
	Next
	
	Print ""
	
	Local s := New TestStruct
	For Local d := Eachin Variant( s ).Type.GetDecls()
		Print "~t" + d
	Next
	
End


Class TestClass
	
	Field a:Int
	Field b:String
	
	Method Show()
		Print a + b
	End	
	
End


Struct TestStruct
	
	Field a:Int
	Field b:String
	
	Method Show()
		Print a + b
	End	
	
End