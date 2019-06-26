tool
extends Reference
class_name Voxel, 'res://addons/VoxelCore/assets/Voxel.png'

# Every Voxel is a Dictionary, not every Dictionary is a Voxel
# Voxels are represented with Dictionaries, following a strict schema, defined below, a wide variety of Voxels can be created
# NOTE: Modifications to the Voxel schema can be done, but should be done in such a way that the original schema is unmodified so as to avoid issues
#
# Schema:
# {
#    const      :   bool         =   Engine.editor_hint,   #   Constant flag, Voxel isn't editable
#    color      :   Color        =   Color(0, 0, 0),       #   Main albedo color when drawn; used as fall back when all else fails
#    colors     :   Dictionary   =   {}, ::                #   Individual albedo colors, define an individual albedo color per face; when not defined fall back is color; used when individual textures positions fail
#       {
#          Vector3.UP        :   Color     =   null   ||   color,
#          Vector3.DOWN      :   Color     =   null   ||   color,
#          Vector3.RIGHT     :   Color     =   null   ||   color,
#          Vector3.LEFT      :   Color     =   null   ||   color,
#          Vector3.BACK      :   Color     =   null   ||   color,
#          Vector3.FORWARD   :   Color     =   null   ||   color
#       }
#    texture    :   Vector2      =   null   ||   color,    #   Main texture position when drawn; used as fall back when both individual texture positions and individual albedo colors fail
#    textures   :   Dictionary   =   {}, ::                #   Individual texture position, define an individual texture position per face; when not defined fall back is individual albedo color, if individual albedo color fails fallback is main texture position
#       {
#          Vector3.UP        :   Vector2     =   null   ||   colors[Vector.UP]        ||   texture,
#          Vector3.DOWN      :   Vector2     =   null   ||   colors[Vector.DOWN]      ||   texture,
#          Vector3.RIGHT     :   Vector2     =   null   ||   colors[Vector.RIGHT]     ||   texture,
#          Vector3.LEFT      :   Vector2     =   null   ||   colors[Vector.LEFT]      ||   texture,
#          Vector3.BACK      :   Vector2     =   null   ||   colors[Vector.BACK]      ||   texture,
#          Vector3.FORWARD   :   Vector2     =   null   ||   colors[Vector.FORWARD]   ||   texture
#       }
#    data       :   Dictionary   =   {}                    #   Custom data, any and all custom data should be placed here so as to avoid conflicts
# }
#
# Example:
# {
#    const      :   true,
#    color      :   Color(0.6, 0.12, 1),
#    colors     :   {
#       Vector3.FORWARD   :   Color(0, 0.33, 0.11),
#       Vector3.DOWN      :   Color(1, 0.6, 0),
#       Vector3.BACK      :   Color(0.13, 0.75, 0.45)
#    },
#    texture    : Vector2(2, 3),
#    textures   :   {
#       Vector.DOWN       :   Vector2(0, 1),
#       Vector.RIGHT      :   Vector2(3, 3)
#    },
#    data       :   {
#       custom   :   3,
#       data     :   'wow'
#    }
# }
#
