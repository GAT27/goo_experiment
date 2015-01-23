//include normals. include UVs, triangulate faces!
/*
var anim;
anim = file_text_open_read(argument[0]);

var v_listX,v_listY,v_listZ,vt_listX,vt_listY,vn_listX,vn_listY,vn_listZ;

var matFileName,matFile;

matFileName = "";//name des Material Files
//show_message(string(argument1));
var material_set;
if (argument_count > 1){//wenn das Argument nicht gesetzt wurde
    material_set = true;
    matFileName = argument[1];//name des Material Files
    
}else{
    material_set = false;    
}

//matFile = file_text_open_read(matFileName);

var vertexColor;
vertexColor = c_white;

v_listX = ds_list_create();
v_listY = ds_list_create();
v_listZ = ds_list_create();

vt_listX = ds_list_create();
vt_listY = ds_list_create();
vt_listZ = ds_list_create();

vn_listX = ds_list_create();
vn_listY = ds_list_create();
vn_listZ = ds_list_create();



var model;
model = ds_list_create();

var zeile,nx,ny,nz,tx,ty,sx,vx,vy,vz;

while (file_text_eof(anim)==false){
    zeile = file_text_read_string(anim);
    
    if (string_char_at(zeile,1) != '#'){ //falls der buchstabe ein Kommentar ist

        switch (string_char_at(zeile,1)){
            case 'v':
            
            switch (string_char_at(zeile,2)){
                case 'n':
                    zeile=string_delete(zeile,1,string_pos(" ",zeile));
                    nx=real(string_copy(zeile,1,string_pos(" ",zeile)));
                    zeile=string_delete(zeile,1,string_pos(" ",zeile));
                    ny=-1*real(string_copy(zeile,1,string_pos(" ",zeile)));
                    zeile=string_delete(zeile,1,string_pos(" ",zeile));
                    nz=real(string_copy(zeile,1,string_length(zeile)));
                    
                    ds_list_add(vn_listX,nx);
                    ds_list_add(vn_listY,ny);
                    ds_list_add(vn_listZ,nz);   
                break;
                
                case 't':
                    zeile=string_delete(zeile,1,string_pos(" ",zeile));
                    tx=real(string_copy(zeile,1,string_pos(" ",zeile)));
                    zeile=string_delete(zeile,1,string_pos(" ",zeile));
                    ty=1-real(string_copy(zeile,1,string_length(zeile)));
                    
                    ds_list_add(vt_listX,tx);
                    ds_list_add(vt_listY,ty); 
                break;
                
                
                default:
                    zeile=string_delete(zeile,1,string_pos(" ",zeile));
                    vx=real(string_copy(zeile,1,string_pos(" ",zeile)));
                    zeile=string_delete(zeile,1,string_pos(" ",zeile));
                    vy=real(string_copy(zeile,1,string_pos(" ",zeile)))*-1;
                    zeile=string_delete(zeile,1,string_pos(" ",zeile));
                    vz=real(string_copy(zeile,1,string_length(zeile)));
                    
                    ds_list_add(v_listX,vx);
                    ds_list_add(v_listY,vy);
                    ds_list_add(v_listZ,vz);
                break;
                
            }
            
            break;
            
            
            case 's':
                zeile=string_delete(zeile,1,string_pos(" ",zeile));
                sx=string(string_copy(zeile,1,string_pos(" ",zeile)));
                if (sx != "off"){
                
                }
            
            break;
            
            
            case 'u':
                if (material_set == true){
                if(string_copy(zeile,2,5) == "semtl"){
                var vertexColorName,matFile;
                
                    zeile=string_delete(zeile,1,string_pos(" ",zeile));
                    vertexColorName=string(string_copy(zeile,1,string_length(zeile))); //Farbenname im ModellFile
                    //show_message(vertexColorName);
                    
                    
                    matFile = file_text_open_read(matFileName);
                    
                    
                    //var zeile,nx,ny,nz,tx,ty,sx,vx,vy,vz;
                    
                    while (file_text_eof(matFile)==false){
                        zeile = file_text_read_string(matFile);
                        
                        if (string_char_at(zeile,1) != '#'){ //falls der buchstabe ein Kommentar ist
                    
                            switch (string_char_at(zeile,1)){
                                
                                case 'n':
                                
                                    if(string_copy(zeile,2,5) == "ewmtl"){
                                    
                                        zeile=string_delete(zeile,1,string_pos(" ",zeile));
                                        vertexColorNameMat=string(string_copy(zeile,1,string_length(zeile))); //Materialname im Material file
                                    }                
                                
                                
                                break;
                                
                                
                                case 'K':
                                
                                switch (string_char_at(zeile,2)){
                                    case 'd':
                                    
                                        if (vertexColorName == vertexColorNameMat){
                                    
                                            zeile=string_delete(zeile,1,string_pos(" ",zeile));
                                            r=real(string_copy(zeile,1,string_pos(" ",zeile)));
                                            zeile=string_delete(zeile,1,string_pos(" ",zeile));
                                            g=real(string_copy(zeile,1,string_pos(" ",zeile)));
                                            zeile=string_delete(zeile,1,string_pos(" ",zeile));
                                            b=real(string_copy(zeile,1,string_length(zeile)));
                                            
                                            r = 255*r;
                                            g = 255*g;
                                            b = 255*b;
                                            
                                            vertexColor = make_color_rgb(r,g,b);
                                        }        
                                    break;
                                    
                                }
                                
                                break;
                            }
                            
                        }
                        file_text_readln(matFile);
                    
                    }
                    
                    file_text_close(matFile);
                    
                    //---------------------------------------------------------------------------------------------------
                }
                }
            
            break;
            
            
            case 'f':
            var f;
            //auf faces reihenfolge achten!
            zeile=string_delete(zeile,1,string_pos(" ",zeile));
            f[0]=string(string_copy(zeile,1,string_pos(" ",zeile)));
            zeile=string_delete(zeile,1,string_pos(" ",zeile));
            f[2]=string(string_copy(zeile,1,string_pos(" ",zeile)));
            zeile=string_delete(zeile,1,string_pos(" ",zeile));
            f[1]=string(string_copy(zeile,1,string_length(zeile)));
            
                var p,z,e1,e2,e3;
                p=0;
                repeat(3){
                    z = f[p];
                    
                    z=string_delete(z,0,string_pos("/",z));
                    e1=string(string_copy(z,1,string_pos("/",z)-1));
                    z=string_delete(z,1,string_pos("/",z));
                    e2=string(string_copy(z,1,string_pos("/",z)-1));
                    z=string_delete(z,1,string_pos("/",z));
                    e3=string(string_copy(z,1,string_length(z)));
                    
                    p+=+1;
                    
                    
                    e1 = real(e1)-1;
                    e3 = real(e3)-1;
                    e2 = real(e2)-1;
                    

                    //adding the information of 1 vertex to the list
                    
                    ds_list_add(model,ds_list_find_value(v_listX,e1));//x
                    ds_list_add(model,ds_list_find_value(v_listY,e1));//y
                    ds_list_add(model,ds_list_find_value(v_listZ,e1));//z
                    
                    ds_list_add(model,vertexColor);//color

                    ds_list_add(model,ds_list_find_value(vt_listX,e2));//u coordinate
                    ds_list_add(model,ds_list_find_value(vt_listY,e2));//v coordinate
                 
                    ds_list_add(model,ds_list_find_value(vn_listX,e3));//x normal
                    ds_list_add(model,ds_list_find_value(vn_listY,e3));//y normal
                    ds_list_add(model,ds_list_find_value(vn_listZ,e3));//z normal
                
                }
                
            
            
            break;
        }
        
    }
    file_text_readln(anim);

}

file_text_close(anim);

d3d_model_primitive_end(model);

//lösche listen
ds_list_destroy(v_listX);
ds_list_destroy(v_listY);
ds_list_destroy(v_listZ);
ds_list_destroy(vt_listX);
ds_list_destroy(vt_listY);
ds_list_destroy(vn_listX);
ds_list_destroy(vn_listY);
ds_list_destroy(vn_listZ);


return model;*/
