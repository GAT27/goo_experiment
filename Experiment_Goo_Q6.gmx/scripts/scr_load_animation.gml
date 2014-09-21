/*
This script loads an animation and returns a list with all animation frames

argument0: animation Path
argument1: first model frame (integer)
argument2: last model frame (integer)
argument3: material path (OPTIONAL!)
*/

var animation_path = argument[0];//animation path (example: "./animation/running"
var animation_start = argument[1];//first model frame of the animation(example: 0);
var animation_end = argument[2];//last model frame of the animation (example: 6);

var material_path = "";
if argument_count > 3
    material_path = argument[3];

var animation_frame_count = animation_end-animation_start+1;

//---------------------------------------------

//Loading every model frame

var model_frame;
for(var j = 0;j<animation_frame_count;j++)
{
    var vals = string_length(string(animation_start+j));
    var dig = string_repeat("0",6-real(vals));
    
    if (material_path == "")//if no material set
        model_frame[j] = scr_load_model_blender_as_list(animation_path+"_"+string(dig)+string(animation_start+j)+".obj");
    else
        model_frame[j] = scr_load_model_blender_as_list(animation_path+"_"+string(dig)+string(animation_start+j)+".obj" , material_path);
}

//---------------------------------------------

//converting the model frames to the special vertex format with animation support

var animation = ds_list_create();//final animation is stored in this list
for(var i = 0;i<animation_frame_count-1;i++)
{
    //var last_index = i+1;
    ds_list_add(animation,scr_create_vb_model(model_frame[i],model_frame[i+1]));
}
ds_list_add(animation,scr_create_vb_model(model_frame[animation_frame_count-1],model_frame[0]));//last animation interpolates between last model frame and first model frame

//---------------------------------------------

//delete now the original model frames which aren't needed anymore
for(var j = 0;j<animation_frame_count;j++)
    ds_list_destroy(model_frame[j]);

//---------------------------------------------

return animation;