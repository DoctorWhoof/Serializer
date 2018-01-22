Namespace myapp3d

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

#Import "../serializer"

#Reflect mojo3d..
#Reflect mojo..
#Reflect std..

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	Field _camera:Camera
	Field _light:Light
	Field _donut:Model
	
	Method New( title:String="Simple mojo3d app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		_scene=Scene.GetCurrent()
		_scene.ClearColor=Color.Black
		
		'create camera
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,0,-5 )
		
		'create light
		_light=New Light
		_light.RotateX( 45 )
		
		Local mat01 := New PbrMaterial( Color.Red )
		mat01.MetalnessFactor = 0.5
		mat01.RoughnessFactor = 0.1
		
		_donut=Model.CreateTorus( 2,.5,48,24,mat01 )
		
		Local  json := New JsonObject
		json.Serialize( "mat01", Variant(mat01) )
		Print json.ToJson()
	End
	
	Method OnRender( canvas:Canvas ) Override
		RequestRender()
		_donut.Rotate( .2,.4,.6 )
		_scene.Update()
		_scene.Render( canvas,_camera )
		canvas.DrawText( "Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
