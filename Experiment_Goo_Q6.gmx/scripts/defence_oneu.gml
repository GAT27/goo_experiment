
switch(argument0)
{
    case 1:     switch(argument1)
                {
                    case 0:     if argument2&7==2
                                {
                                    actor_one.buffer_ch=15;
                                    return 32;
                                }
                    case 32:    if actor_one.buffer_ch==0
                                {
                                    return 0;
                                }
                    default:    return actor_one.move;
                }
    
    case 2:     sprite_assign(block_tmp,block_blue);
                actor_one.char_select = 2;
                return 5;
}