Current Features / Properties
* Drawing layers of mesh with offset and mask
* Fur length
* Gravity
* Swing as wind blowing
* Occlusion

Shaders
* Shader `Custom/Fur(20 Layer)`
  * 20 pass cut-off fur shader
  * not support shadow
  * not support multi-lighting
* Shader `Custom/Fur(DX11)`
  * 1 pass cut-off fur shader
  * need geometry shader supported
  * support shadow
  * support multi-lighting
  * only support forward-path

Note
This classical fur effect uses lots of draw calls per light per object. And Unity is not support multi-pass shadow caster, so the first shader cannot draw shadow currectly.

I tried to write a geometry shader version to instead of multi-pass. The dx11 version only need 1 draw call per light per object, and shadow caster pass works well.

I tried the custom BRDF too, but it has problems in linear color space need fixed.

It's also can be implemented as a deferred version for performance on multi-lighting, to reduce the calculating in geometry shader.

Ref
* Fur Effects - http://www.xbdev.net/directx3dx/specialX/Fur/
* Unity的PBR扩展——皮毛材质 - https://zhuanlan.zhihu.com/p/57897827