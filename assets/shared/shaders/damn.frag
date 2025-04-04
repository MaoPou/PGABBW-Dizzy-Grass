#pragma header

uniform float iTime;

vec2 curve(vec2 uv)
{
	uv = (uv - 0.5) * 2.0;
	uv *= 1.1;	
	uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 1.85);
	uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 1.85);
	uv  = (uv / 2.0) + 0.5;
	uv =  uv *0.92 + 0.04;
	return uv;
}

void main()
{
    vec2 q = openfl_TextureCoordv;
    vec2 uv = q;
    uv = curve( uv );
    vec3 oricol = flixel_texture2D( bitmap, vec2(q.x,q.y) ).xyz;
    vec3 col;
	float x =  sin(0.6*iTime+uv.y*21.0)*sin(0.7*iTime+uv.y*29.0)*sin(1.5+1.5*iTime+uv.y*31.0)*0.0017;

    col.r = flixel_texture2D(bitmap,vec2(x+uv.x+0.001,uv.y+0.001)).x+0.05;
    col.g = flixel_texture2D(bitmap,vec2(x+uv.x+0.000,uv.y-0.002)).y+0.05;
    col.b = flixel_texture2D(bitmap,vec2(x+uv.x-0.002,uv.y+0.000)).z+0.05;
    col.r += 0.00*flixel_texture2D(bitmap,0.75*vec2(x+0.025, -0.027)+vec2(uv.x+0.001,uv.y+0.001)).x;
    col.g += 0.00*flixel_texture2D(bitmap,0.75*vec2(x+-0.022, -0.02)+vec2(uv.x+0.000,uv.y-0.002)).y;
    col.b += 0.00*flixel_texture2D(bitmap,0.75*vec2(x+-0.02, -0.018)+vec2(uv.x-0.002,uv.y+0.000)).z;

    col = clamp(col*0.6+0.4*col*col*1.0,0.0,1.0);

    float vig = (0.0 + 1.0*16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y) + 0.3);
	col *= vec3(pow(vig,1.0));

    col *= vec3(1.0,1.0,1.0);
	col *= 2.8;

	float scans = clamp(0.35+0.35*sin(0.0*iTime+uv.y*openfl_TextureSize.y*1.5), 0.0, 1.0);
	
	float s = pow(scans,1.7);
	col = col*vec3( 0.4+0.7*s) ;

    col *= 1.0+0.01*sin(110.0*iTime);
	if (uv.x < 0.0 || uv.x > 1.0)
		col *= 0.0;
	if (uv.y < 0.0 || uv.y > 1.0)
		col *= 0.0;
	
	col*=1.0-0.65*vec3(clamp((mod(openfl_TextureCoordv.x, 2.0)-1.0)*2.0,0.0,1.0));
	
    float comp = smoothstep( 0.1, 0.9, sin(iTime) );
 
	// Remove the next line to stop cross-fade between original and postprocess

    gl_FragColor = vec4(col,flixel_texture2D(bitmap, uv).a);
}
