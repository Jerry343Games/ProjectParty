Thanks for buying Easy Toon Shader.
If you have any issue or idea on what can be improved, feel free to reach me: izzynab.publisher@gmail.com
Documentation: https://inabstudios.gitbook.io/easy-toon-shader/

After importing the package, everything will function right away. With East Toon shader, you can easily make new materials.
When you switch from standard material to East Toon material, the values and textures remain the same because East Toon kept Unity's standard shader parameter variables.

Asset Layout:
BakedMeshes - folder used as default root for saving baked meshes with SmoothNormalsBaker
Editor - folder containing all scripts of the tools and custom material inspector
Examples - you can easily delete this folder
Demo Assets - models, scripts and textures used in demo scenes
Scenes: DemoRoom - WebGl demo | Base - Scenes displaying all of the asset's capabilities
Showcase Materials - materials used in DemoRoom scene
Shader - this folder contains EasyToon shader.
Textures
LightRamps - contains RampTexture import settings and 12 showcase light ramp textures.


You can bake smoothed normals tool inside meshes to achieve good-looking outlines even with flat-shaded meshes. You can find the window under Tools/SmoothNormalsBaker. 
Simply by adding them to the Meshes array, you can bake multiple meshes at once.
The location of baked meshes can be changed manually, to the same folder as the array's first mesh, or to the default location (Assets/EastToon Shader/BakedMeshes,
you can always change the default location in SmoothNormalsBaker.cs code in DefaultPath field)
Please avoid attempting to use the default location if you delete this folder or move the Easy Toon asset, as doing so will result in an error.

Use DffuseRamp mode with the gradient editor if you want total control over the shadows and colors of the bright and dark areas of your object. After creating a gradient, you must export it as a PNG file to your project files. 
The exported texture must then be manually dragged and dropped into the Light Ramp Texture property box. The ramp won't be saved if you don't do that.