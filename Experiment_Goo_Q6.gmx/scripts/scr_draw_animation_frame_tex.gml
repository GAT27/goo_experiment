/*
    This script draws the animation and calculates the interpolation variable
    argument3: texture id
    
    use this script if you want to draw an animation with a texture applied to it.
*/

var animation_list = argument0;//animation list which contains preprocessed vertex-buffers with all animation frames
var animation_step = argument1; //current animation step (must be between 0 and "animation_length";
var animation_length = argument2;//maximum animation step 
var tex = argument3;//texture

var pc = (animation_step/animation_length);//calculate (in percent from 0 to 1) the animation progress (from 0 to 1)
var frame_count = ds_list_size(animation_list);
shader_set_uniform_f(global.shader_interpol, pc*frame_count-floor(pc*frame_count));//calculate the interpolation value from the current frame to the next frame

var current_frame = floor(pc*frame_count); //calculate the current frame
vertex_submit(ds_list_find_value(animation_list,current_frame),pr_trianglelist,tex);//submit the model