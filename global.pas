unit global;

uses Graph3D;

var brightBallMaterial := Materials.Diffuse(RGB(255, 163, 117)) 
	+ Materials.Specular(150,100) + Materials.Emissive(GrayColor(0));
var darkBallMaterial := Materials.Diffuse(RGB(110,  51,  26)) 
	+ Materials.Specular(150,100) + Materials.Emissive(GrayColor(30));
var boardMaterial := Materials.Diffuse(RGB(110,  51,  26)) 
	+ Materials.Specular(150,100) + Materials.Emissive(GrayColor(0));

end.