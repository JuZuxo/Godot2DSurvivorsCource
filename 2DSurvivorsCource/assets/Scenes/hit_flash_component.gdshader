shader_type canvas_item;

uniform float lerp_percent : hint_range(0.0, 1.0); //uniform就是export
//这个函数会用到所有像素点上
void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);  //texture_color其实就是整个sprite的颜色
	vec4 final_color = mix(texture_color, vec4(1.0,1.0,1.0,texture_color.a),lerp_percent);
	COLOR = final_color;	//texture_color.a就是用这个sprite的alpha颜色，给他铺成白色，后面的1.0表示透明度
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
