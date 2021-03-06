#define BASIC_SET

if is_real(argument0) and !argument0
{   BS_prepare();
    BS_movement();
    BS_attacking();
    BS_reacting();
}
else
{   BS_cleanup(argument0);
    exit;
}

/*Frame advancement, attribute containers created in BS_attacking
00: hbox:       created hitbox id
01: move:       attack action [(>=64),]
02: frame:      attack action frame part [,(0,1,2,3,4;5-6)]
03: buffer_af:  attack action frame stage counter
04: htx:        hitbox x position, stores hit after hbox is destroyed
05: hty:        hitbox y position
06: hzx:        hitbox x length (width)
07: hzy:        hitbox y length (height)
08: s_part:     secondary attacks action stage
09: t_part:     secondary attacks action timer
10: h_firm:     hit confirm
*/if ds_list_size(abox)
for (var i=ds_list_size(abox)-1;i>=0;i--)
{   cbox = abox[|i];
    hbox = cbox[0];
    move = cbox[1];
    frame = cbox[2];
    buffer_af = cbox[3];
    htx = cbox[4];
    hty = cbox[5];
    hzx = cbox[6];
    hzy = cbox[7];
    
    switch frame
    {   case 1:     if buffer_af <= 1//Get active frame
                    {   buffer_af = action[move,frame];
                        frame++;
                        hbox = instance_create(x+htx-hzx/2,y-hty-hzy/2,hitbox);
                        hbox.hit = 1;
                        hbox.bx = hbox.x + hzx;
                        hbox.by = hbox.y + hzy;
                        hbox.x2 = hzx;
                        hbox.y2 = hzy;
                    }
                    else
                        buffer_af--;//Stay in start up frame
                    break;
                    
        case 2:     if buffer_af <= 1//Get recovery frame
                    {   buffer_af = action[move,frame];
                        frame++;
                        if !action[move,frame]
                        {   htx = hbox.hit;
                            with hbox instance_destroy();
                        }
                    }
                    else
                        buffer_af--;//Stay in active frame
                    break;
                    
        case 3:     if buffer_af <= 1//Get lingering frame
                    {   buffer_af = action[move,frame];
                        frame++;
                    }
                    else
                        buffer_af--;//Stay in recovery frame
                    break;
                    
        case 4:     if buffer_af <= 0//End frame
                    {   if instance_exists(hbox)
                            with hbox instance_destroy();
                        frame++;
                    }
                    else
                        buffer_af--;//Stay in lingering frame
                    break;
                    
        default:    buffer_mtr -= action[move,0]//Buffer total cost
                                + action[move,1]
                                + action[move,2] + 1;
                    buffer_af = action[move,frame];//Get start up frame
    }
    
    cbox[0] = hbox;
    cbox[1] = move;
    cbox[2] = frame;
    cbox[3] = buffer_af;
    cbox[4] = htx;
    //Prepare for attack removal after a cancel
    if cancel and (cancel&1) and !(action[move,3] and frame>1)
    {   if instance_exists(hbox)
            hbox.visible = 0;
        else
        {   cbox = 0;
            ds_list_delete(abox,i);
        }
    } 
    cancel = floor(cancel/2);
    //real time update testing
}


#define BS_prepare

//Buffer meter, full control reset
if buffer_mtr < 60
{   buffer_mtr++;
    if buffer_mtr >= 60
    {   buffer_mtr = 60;
        cancel = 0;
        sty = -1;
        if trig_br
        {   trig_br = 0;
            skin = tmp_skin;
        }
    }
}

//Buffer cost, may be useless
/*if buffer_ch > 0
{
    buffer_ch--;
    if buffer_ch < 0
        buffer_ch = 0;
}*/

//Buffer bank, holds up to 6+1 directions, no use yet
bank = buffer_bk & 15;
arrow = data & 15
if !(bank==arrow)
{   if buffer_bk > 16777215
        buffer_bk &= 16777215;
    buffer_bk = (buffer_bk<<4) + arrow;
    heldb = 5;
}
else
{   heldb--;
    if heldb < 0
        buffer_bk = 0;
}

//Physics adjustment
if !lifted and ((state<=16) or (state==33) or (state>=35 and state<=41) or (state>=44 and state<=46)
or (state==51) or (state>=55 and state<=58))// or (state>=64)
{   grounded = 1;
    gvy = 0;
    //gvydam = 0;
    djmp = 1;
    if !(state==5)//Ignore when forward dashing
    {   if x < oppose.x//Being on the left
        {   forward = 6;
            backward = 4;
        }
        else//Being on the right
        {   forward = 4;
            backward = 6;
        }
    }
    if place_meeting(x + hspeed,y,oppose) and oppose.grounded
    {   if (oppose.walled==1) and (hspeed>0)//Right side
            walled = 2;
        else if (oppose.walled==3) and (hspeed<0)//Left side
            walled = 4;
        else
            oppose.x += hspeed;
    }
}
else
{   grounded = 0;
    gvy += grav;
    while place_meeting(x,y,groundf)
        x += forward-5;
    if place_meeting(x,y + vspeed + grav,groundf)
    or place_meeting(x,y + vspeed + gvydam,groundf)
    {   y = floor(y);
        while !place_meeting(x,y + 1,groundf)
            y++;
        x += hspeed;
        vspeed = 0;
        grounded = 1;
        lifted = 0;
        airborne = 0;
        if x < oppose.x//Landing on the left
        {   while place_meeting(x,y,oppose)
            {   if place_meeting(x - 1,y,groundf)
                    oppose.x++;
                else
                    x--;
            }
            forward = 6;
            backward = 4;
        }
        else//Landing on the right
        {   while place_meeting(x,y,oppose)
            {   if place_meeting(x + 1,y,groundf)
                    oppose.x--;
                else
                    x++;
            }
            forward = 4;
            backward = 6;
        }
    }
}
////
with oppose if (x<oppose.x)//Special case to handle left side fallthrough
while place_meeting(x,y,groundf)
    x++;
if x < oppose.x
while place_meeting(x,y,groundf)
    x++;
////
if place_meeting(x + abs(hspeed) + 1,y,groundf)//Wall to the right
{   x = floor(x);
    while !place_meeting(x + 1,y,groundf)
        x++;
    while place_meeting(x,y,groundf)
        x--;
    walled = 1;
}
else if walled == 2//Opponent to the right
{   x = floor(x);
    while !place_meeting(x + 1,y,oppose)
        x++;
    while place_meeting(x,y,oppose)
        x--;
    walled--;
}
else if place_meeting(x - abs(hspeed) - 1,y,groundf)//Wall to the left
{   x = floor(x);
    while !place_meeting(x - 1,y,groundf)
        x--;
    while place_meeting(x,y,groundf)
        x++;
    walled = 3;
}
else if walled == 4//Opponent to the left
{   x = floor(x);
    while !place_meeting(x - 1,y,oppose)
        x--;
    while place_meeting(x,y,oppose)
        x++;
    walled--;
}
else
    walled = 0;

//Jump checking
if grounded
{   jump = (data>>6)&1;
    heldj = 0;
}
else
{   if heldj
    {   jump = (data>>6)&1;
        if jump
            airborne = 0;
    }
    else
        jump = 0;
    heldj = !((data>>6)&1);
}

//Attack checking
if (data>>4)&3 == 0
{   attack = (data>>4)&3;
    helda = 1;
}
else if helda
{   attack = (data>>4)&3;
    helda = 0;
}
else
    attack = 0;

//Passive controls
shoulder = (data>>7)&3;
if shoulder == 1//Shielding and breaking
{   walk_sp[4] = charge_for * 0.2;
    walk_sp[7] = charge_bck * 0.2;
    if trig_ps < 0
        trig_ps = 2 * defense_cor;
    else if trig_ps
        trig_ps--;
    
    if ds_list_size(abox) and grounded and !trig_br and (buffer_mtr<60)
    {   var cbox = abox[|ds_list_size(abox)-1];
        if (cbox[2]==2 and ((cbox[1]>=192 and cbox[1]<224) or (oppose.sty>=0 and !cbox[0].hit)))
        or (cbox[2]==3 and ((cbox[1]>=192 and cbox[1]<224) or (oppose.sty>=0 and !cbox[4])))
        {   trig_br = 1;
            tmp_skin = skin;//SKIN CHANGE
        }
    }
}
else if shoulder == 2//Charging
{   walk_sp[4] = charge_for * 1.2;
    walk_sp[7] = charge_bck * 1.2;
    charge += power_sec / 10;
}
else//Nothing held
{   walk_sp[4] = charge_for;
    walk_sp[7] = charge_bck;
    trig_ps = -1;
}

//Meter limits
if life < 1
    stager.clock_s = 0;//END MATCH
if will <= 0
{   stock--;
    if !stock
        stager.clock_s = 0;//END MATCH
    else
    {   shield = 400;
        will = 2000;
        oppose.will = 2000;
    }
}
if (gauge<0 and !goo) or (goo<0)
{   gauge = 0;
    goo = 0;
}
////
life += 4*stamina_pri/room_speed;//Life regen
boost += 3*speed_pri/(2+(oppose.boost==100))/room_speed;//Boost regen
if !(shoulder==1)//Shield regen
    shield += 0 / room_speed;//2;
if !(shoulder==2) and (trig_ch<=0)//Passive charging
    charge -= 2 / room_speed;
else
{   trig_ch--;
    if trig_ch < 0
        trig_ch = 0;
}
if charge < 0
    charge = 0;
////
if life > 10000
    life = 10000;
if boost > 100
    boost = 100;
if shield > min(400,will)
    shield = min(400,will);
if charge > (20*stock)
{   charge = 20 * stock;
    if trig_ch <= 0
        trig_ch = 2 * room_speed;
}
if (gauge>=300+40*goo) or (goo==7)
{   if goo == 7
        gauge = 0;
    else
    {   gauge -= 300+40*goo;
        goo++;
    }
}

move = state;


#define BS_movement

//Break controls
if trig_br and !(shoulder==1) and grounded and (goo or boost==100)
{   skin = background_get_texture(back_tmp);
    
    //Focus break
    if goo and (arrow>=6) or (arrow==4)
    {   if (arrow>=4 and arrow<=6)//Dashing
        {   if arrow == forward
                state = 5;
            else
                state = 8;
            dash = dasl[state];
            dask = 1;
        }
        else///Jumping
        {   if arrow == forward+3
                state = 17;
            else if arrow == backward+3
                state = 20;
            else
                state = 23;
            heldlr = !(arrow==8);
            grounded = 0;
            vspeed = -grav;
        }
        buffer_mtr = 60;
        gauge = floor(gauge*gauge / (300+40*goo));
        goo--;
        trig_br = 0;
        if !cancel
            cancel = 1 + ((attack==1 and goo) or (attack>1));
        else
            cancel += power(4,(attack==1 and goo) or (attack>1));
        skin = tmp_skin;
    }
    
    //Shift break
    else if (boost==100) and (shoulder==2)
    {   state = 0;
        buffer_mtr = 60;
        boost -= 100;
        trig_br = 0;
        if !cancel
            cancel = 1;
        else
            cancel += 1;
        /*if (attack==1 and goo) or (attack>1)
            cancel = 2;
        else
            cancel = 1;*/
        skin = tmp_skin;
    }
}

//Movement controls(b4 f6)
if (buffer_mtr>59) and !(state>=32 and state<64) switch state
{   //Neutral stand
    case 0:     hspeed = 0;
                vspeed = 0;
                ////
                if jump//Goto prepare jump
                    move = 16;
                else if (arrow==forward) or (arrow==forward+3)//Goto prepare forward walk
                    move = 3;
                else if (arrow==backward) or (arrow==backward+3)//Goto prepare back walk
                    move = 6;
                else if (arrow==forward-3) or (arrow==backward-3)//Goto crouching
                or (arrow==2)
                    move = 9;
                else if arrow == 8//Goto looking up
                    move = 10;
                else//Stay here
                    move = state;
                break;
                
    //Prepare forward walk
    case 3:     if dast <= 0//Dash trigger
                    dast = dasc;
                dast--;
                if !(arrow==forward or arrow==forward+3)//Let go forward
                {   hspeed = 0;
                    if (dast>0) and (arrow==5)//Then go to neutral
                        dash = dasl[state+2];
                }
                else
                    hspeed = walk_sp[4] * (forward-5);
                ////
                if jump//Goto to prepare jump
                {   move = 16;
                    dast = 0;
                    dash = 0;
                }
                else if dash and (arrow==forward)//Goto forward dash
                {   move = 5;
                    dast = 0;
                }
                else if dast <= 0//Goto forward walk
                {   move = 4;
                    dash = 0;
                }
                else if (arrow==backward) or (arrow==backward+3)//Goto prepare back walk
                {   move = 6;
                    dast = 0;
                    dash = 0;
                }
                else if (arrow==forward-3) or (arrow==backward-3)//Goto crouching
                or (arrow==2)
                {   move = 9;
                    dast = 0;
                    dash = 0;
                }
                else if arrow == 8//Goto looking up
                {   move = 10;
                    dast = 0;
                    dash = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Forward walk
    case 4:     if jump//Goto prepare jump
                    move = 16;
                else if (arrow==forward) or (arrow==forward+3)//Stay here
                {   hspeed = walk_sp[4] * (forward-5);
                    move = state;
                }
                else if (arrow==backward) or (arrow==backward+3)//Goto prepare back walk
                    move = 6;
                else if (arrow==forward-3) or (arrow==backward-3)//Goto crouching
                or (arrow==2)
                    move = 9;
                else if arrow == 8//Goto looking up
                    move = 10;
                else//Goto neutral stand
                    move = 0;
                break;
                
    //Forward dash
    case 5:     hspeed = walk_sp[state] * (forward-5);
                if dask
                    dask = hspeed;
                dash--;//Dash until end duration
                ////
                if arrow == 2//Goto crouching
                {   move = 9;
                    dash = 0;
                    dask = 0;
                }
                else if dash <= 0//Goto neutral stand
                {   move = 0;
                    dask = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Prepare back walk
    case 6:     if dast <= 0//Dash trigger
                    dast = dasc;
                dast--;
                if !(arrow==backward or arrow==backward+3)//Let go backward
                {   hspeed = 0;
                    if (dast>0) and (arrow==5)//Then go to neutral
                        dash = dasl[state+2];
                }
                else
                    hspeed = walk_sp[7] * (backward-5);
                ////
                if jump//Goto prepare jump
                {   move = 16;
                    dast = 0;
                    dash = 0;
                }
                else if dash and (arrow==backward)//Goto back dash
                {   move = 8;
                    dast = 0;
                }
                else if dast <= 0//Goto back walk
                {   move = 7;
                    dash = 0;
                }
                else if (arrow==forward) or (arrow==forward+3)//Goto prepare forward walk
                {   move = 3;
                    dast = 0;
                    dash = 0;
                }
                else if (arrow==forward-3) or (arrow==backward-3)//Goto crouching
                or (arrow==2)
                {   move = 9;
                    dast = 0;
                    dash = 0;
                }
                else if arrow == 8//Goto looking up
                {   move = 10;
                    dast = 0;
                    dash = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Back walk
    case 7:     if jump//Goto prepare jump
                    move = 16;
                else if (arrow==backward) or (arrow==backward+3)//Stay here
                {   hspeed = walk_sp[7] * (backward-5);
                    move = state;
                }
                else if (arrow==forward) or (arrow==forward+3)//Goto prepare forward walk
                    move = 4;
                else if (arrow==forward-3) or (arrow==backward-3)//Goto crouching
                or (arrow==2)
                    move = 9;
                else if arrow == 8//Goto looking up
                    move = 10;
                else//Goto neutral stand
                    move = 0;
                break;
                
    //Back dash
    case 8:     hspeed = walk_sp[state] * (backward-5);
                if dask
                    dask = hspeed;
                dash--;//Dash until end duration
                ////
                if arrow == 2//Goto crouching
                {   move = 9;
                    dash = 0;
                    dask = 0;
                }
                else if dash <= 0//Goto neutral stand
                {   move = 0;
                    dask = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Crouching
    case 9:     hspeed = 0;
                vspeed = 0;
                ////
                if jump//Goto prepare jump
                    move = 16;
                else if arrow == forward//Goto prepare forward walk
                    move = 3;
                else if arrow == backward//Goto prepare back walk
                    move = 6;
                else if (arrow==forward-3) or (arrow==backward-3)//Stay here
                or (arrow==2)
                    move = state;
                else//Goto neutral stand
                    move = 0;
                break;
                
    //Looking up
    case 10:    hspeed = 0;
                vspeed = 0;
                ////
                if jump//Goto prepare jump
                    move = 16;
                else if (arrow==forward) or (arrow==forward+3)//Goto prepare forward walk
                    move = 3;
                else if (arrow==backward) or (arrow==backward+3)//Goto prepare back walk
                    move = 6;
                else if arrow == 8//Stay here
                    move = state;
                else//Goto neutral stand
                    move = 0;
                break;
                
    //Prepare jump
    case 16:    hspeed = 0;
                vspeed = 0;
                ////
                if plag <= 0//Execute jump
                {   if (arrow==forward+3) or (arrow==forward-3)
                    or (arrow==forward)
                    {   if (data>>6)&1
                            move = 17;//Goto forward jump
                        else
                            move = 28;//Goto forward hop
                        heldlr = 1;
                    }
                    else if (arrow==backward+3) or (arrow==backward-3)
                    or (arrow==backward)
                    {   if (data>>6)&1
                            move = 20;//Goto back jump
                        else
                            move = 29;//Goto back hop
                        heldlr = 1;
                    }
                    else
                    {   if (data>>6)&1
                            move = 23;//Goto neutral jump
                        else
                            move = 30;//Goto neutral hop
                        if arrow == 2
                            heldlr = 1;
                        else
                            heldlr = 0;
                    }
                    vspeed = -grav;
                }
                plag--;
                break;
                
    //Forward jump
    case 17:    if !grounded
                {   hspeed = walk_sp[state] * (forward-5);
                    vspeed = -walk_sp[23] + gvy;
                }
                ////
                if grounded//Goto crouching
                    move = 9;
                else if djmp and jump//Do a second jump
                {   if (arrow==forward+3) or (arrow==forward-3)//Repeat here
                    or (arrow==forward)
                        move = state;
                    else if (arrow==backward+3) or (arrow==backward-3)//Goto back jump
                    or (arrow==backward)
                        move = 20;
                    else//Goto neutral jump
                        move = 23;
                    gvy = 0;
                    djmp = 0;
                    heldlr = 0;
                }
                else if !heldlr and (arrow==forward or arrow==forward+3)//Goto prepare forward air
                {   move = 18;
                    ptate = state;
                }
                else if (arrow==backward) or (arrow==backward+3)//Goto prepare back air
                {   move = 21;
                    ptate = state;
                    heldlr = 0;
                }
                else if !heldlr and (arrow>=1 and arrow<=3)//Goto prepare down air
                {   move = 26;
                    ptate = state;
                }
                else//Stay here
                    move = state;
                ////
                if !(arrow==forward+3 or arrow==forward-3//Double tapping in air
                or arrow==forward or arrow==2)
                    heldlr = 0;
                break;
                
    //Prepare forward air
    case 18:    if !grounded
                {   if dast <= 0//Dash trigger
                        dast = dasc;
                    dast--;
                    if !(arrow==forward or arrow==forward+3)//Let go forward
                    and (dast>0) and (arrow==5)//Then go to neutral
                        dash = dasl[state+1];
                    if ptate==30
                        vspeed = -walk_sp[30] + gvy;
                    else
                        vspeed = -walk_sp[23] + gvy;
                }
                ////
                if grounded
                {   if ptate==30//Goto neutral stand
                        move = 0;
                    else//Goto crouching
                        move = 9;
                    dast = 0;
                    dash = 0;
                }
                else if djmp and jump//Do a second jump
                {   if (arrow==forward+3) or (arrow==forward-3)//Goto forward jump
                    or (arrow==forward)
                        move = 17;
                    else if (arrow==backward+3) or (arrow==backward-3)//Goto back jump
                    or (arrow==backward)
                        move = 20;
                    else//Goto neutral jump
                        move = 23;
                    dast = 0;
                    dash = 0;
                    gvy = 0;
                    djmp = 0;
                }
                else if dash and djmp and (arrow==forward)//Goto forward air dash
                {   move = 19;
                    dast = 0;
                    djmp = 0;
                }
                else if dast <= 0
                {   if (ptate==23) and !airborne//Goto forward flip
                    {   move = 24;
                        heldlr = 1;
                        gvy = gvy/2;
                    }
                    else//Return to previous state
                        move = ptate;
                    dash = 0;
                }
                else if (arrow==backward) or (arrow==backward+3)//Goto prepare back air
                {   move = 21;
                    dast = 0;
                    dash = 0;
                }
                else if (arrow==forward-3) or (arrow==backward-3)//Goto prepare down air
                or (arrow==2)
                {   move = 26;
                    dast = 0;
                    dash = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Forward air dash
    case 19:    hspeed = walk_sp[state] * (forward-5);
                vspeed = 0;
                dash--;//Dash until end duration
                ////
                if dash <= 0//Goto forward jump
                {   move = 17;
                    gvy = walk_sp[23];
                    dash = 0;
                    airborne = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Back jump
    case 20:    if !grounded
                {   hspeed = walk_sp[state] * (backward-5);
                    vspeed = -walk_sp[23] + gvy;
                }
                ////
                if grounded//Goto crouching
                    move = 9;
                else if djmp and jump//Do a second jump
                {   if (arrow==forward+3) or (arrow==forward-3)//Goto forward jump
                    or (arrow==forward)
                        move = 17;
                    else if (arrow==backward+3) or (arrow==backward-3)//Repeat here
                    or (arrow==backward)
                        move = state;
                    else
                        move = 23;//Goto neutral jump
                    gvy = 0;
                    djmp = 0;
                    heldlr = 0;
                }
                else if (arrow==forward or arrow==forward+3)//Goto prepare forward air
                {   move = 18;
                    ptate = state;
                    heldlr = 0;
                }
                else if !heldlr and (arrow==backward or arrow==backward+3)//Goto prepare back air
                {   move = 21;
                    ptate = state;
                }
                else if !heldlr and (arrow>=1 and arrow<=3)//Goto prepare down air
                {   move = 26;
                    ptate = state;
                }
                else//Stay here
                    move = state;
                ////
                if !(arrow==backward+3 or arrow==backward-3//Double tapping in air
                or arrow==backward or arrow==2)
                    heldlr = 0;
                break;
                
    //Prepare back air
    case 21:    if !grounded
                {   if dast <= 0//Dash trigger
                        dast = dasc;
                    dast--;
                    if !(arrow==backward or arrow==backward+3)//Let go backward
                    and (dast>0) and (arrow==5)//Then go to neutral
                        dash = dasl[state+1];
                    if ptate==30
                        vspeed = -walk_sp[30] + gvy;
                    else
                        vspeed = -walk_sp[23] + gvy;
                }
                ////
                if grounded
                {   if ptate==30//Goto neutral stand
                        move = 0;
                    else//Goto crouching
                        move = 9;
                    dast = 0;
                    dash = 0;
                }
                else if djmp and jump//Do a second jump
                {   if (arrow==forward+3) or (arrow==forward-3)//Goto forward jump
                    or (arrow==forward)
                        move = 17;
                    else if (arrow==backward+3) or (arrow==backward-3)//Goto back jump
                    or (arrow==backward)
                        move = 20;
                    else
                        move = 23;//Goto neutral jump
                    dast = 0;
                    dash = 0;
                    gvy = 0;
                    djmp = 0;
                }
                else if dash and djmp and (arrow==backward)//Goto back air dash
                {   move = 22;
                    dast = 0;
                    djmp = 0;
                }
                else if dast <= 0
                {   if (ptate==23) and !airborne//Goto back flip
                    {   move = 25;
                        heldlr = 1;
                        gvy = gvy/2;
                    }
                    else//Return to previous state
                        move = ptate;
                    dash=0;
                }
                else if (arrow==forward) or (arrow==forward+3)//Goto prepare forward air
                {   move = 18;
                    dast = 0;
                    dash = 0;
                }
                else if (arrow==forward-3) or (arrow==backward-3)//Goto prepare down air
                or (arrow==2)
                {   move = 26;
                    dast = 0;
                    dash = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Back air dash
    case 22:    hspeed = walk_sp[state] * (backward-5);
                vspeed = 0;
                dash--;//Dash until end duration
                ////
                if dash <= 0//Goto back jump
                {   move = 20;
                    gvy = walk_sp[23];
                    dash = 0;
                    airborne = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Neutral jump
    case 23:    if !grounded
                {   if !airborne
                    {   hspeed = 0;
                        vspeed = -walk_sp[state] + gvy;
                    }
                    else
                        vspeed += grav;
                }
                ////
                if grounded//Goto crouching
                    move = 9;
                else if djmp and jump//Do a second jump
                {   if (arrow==forward+3) or (arrow==forward-3)//Goto forward jump
                    or (arrow==forward)
                        move = 17;
                    else if (arrow==backward+3) or (arrow==backward-3)//Goto back jump
                    or (arrow==backward)
                        move = 20;
                    else//Repeat here
                        move = state;
                    gvy = 0;
                    djmp = 0;
                }
                else if (arrow==forward) or (arrow==forward+3)//Goto prepare forward jump
                {   move = 18;
                    ptate = state;
                }
                else if (arrow==backward) or (arrow==backward+3)//Goto prepare back jump
                {   move = 21;
                    ptate = state;
                }
                else if !heldlr and (arrow>=1 and arrow<=3)//Goto prepare down air
                {   move = 26;
                    ptate = state;
                }
                else//Stay here
                    move = state;
                ////
                if !(arrow>=1 and arrow<=3)//Double tapping in air
                    heldlr = 0;
                break;
                
    //Forward flip
    case 24:    if !grounded
                {   hspeed = walk_sp[state] * (forward-5);
                    vspeed = -walk_sp[23] + gvy;
                }
                ////
                if grounded//Goto crouching
                    move = 9;
                else if djmp and jump//Do a second jump
                {   if (arrow==forward+3) or (arrow==forward-3)//Goto forward jump
                    or (arrow==forward)
                        move = 17;
                    else if (arrow==backward+3) or (arrow==backward-3)//Goto back jump
                    or (arrow==backward)
                        move = 20;
                    else//Goto neutral jump
                        move = 23;
                    gvy = 0;
                    djmp = 0;
                }
                else if !heldlr and (arrow==forward or arrow==forward+3)//Goto prepare forward air
                {   move = 18;
                    ptate = state;
                }
                else if (arrow==backward) or (arrow==backward+3)//Goto prepare back air
                {   move = 21;
                    ptate = state;
                    heldlr = 0;
                }
                else if !heldlr and (arrow==forward-3 or arrow==backward-3//Goto prepare down air
                or arrow==2)
                {   move = 26;
                    ptate = state;
                }
                else//Stay here
                    move = state;
                ////
                if !(arrow==forward+3 or arrow==forward-3//Double tapping in air
                or arrow==forward or arrow==2)
                    heldlr = 0;
                break;
                
    //Back flip
    case 25:    if !grounded
                {   hspeed = walk_sp[state] * (backward-5);
                    vspeed = -walk_sp[23] + gvy;
                }
                ////
                if grounded//Goto crouching
                    move = 9;
                else if djmp and jump//Do a second jump
                {   if (arrow==backward+3) or (arrow==backward-3)//Goto back jump
                    or (arrow==backward)
                        move = 20;
                    else if (arrow==forward+3) or (arrow==forward-3)//Goto forward jump
                    or (arrow==forward)
                        move = 17;
                    else//Goto neutral jump
                        move = 23;
                    gvy = 0;
                    djmp = 0;
                }
                else if !heldlr and (arrow==backward or arrow==backward+3)//Goto prepare back air
                {   move = 21;
                    ptate = state;
                }
                else if (arrow==forward) or (arrow==forward+3)//Goto prepare forward air
                {   move = 18;
                    ptate = state;
                    heldlr = 0;
                }
                else if !heldlr and (arrow==forward-3 or arrow==backward-3//Goto prepare down air
                or arrow==2)
                {   move = 26;
                    ptate = state;
                }
                else//Stay here
                    move = state;
                ////
                if !(arrow==backward+3 or arrow==backward-3//Double tapping in air
                or arrow==backward or arrow==2)
                    heldlr = 0;
                break;
                
    //Prepare down air
    case 26:    if !grounded
                {   if dast <= 0//Dash trigger
                        dast = dasc;
                    dast--;
                    if !(arrow==forward-3 or arrow==backward-3 or arrow==2)//Let go down
                    and (dast>0) and (arrow==5)//Then go to neutral
                        dash = dasl[state+1];
                    vspeed = -walk_sp[23] + gvy;
                }
                ////
                if grounded//Goto crouching
                {   move = 9;
                    dast = 0;
                    dash = 0;
                }
                else if djmp and jump//Do a second jump
                {   if (arrow==forward+3) or (arrow==forward-3)//Goto forward jump
                    or (arrow==forward)
                        move = 17;
                    else if (arrow==backward+3) or (arrow==backward-3)//Goto back jump
                    or (arrow==backward)
                        move = 20;
                    else
                        move = 23;//Goto neutral jump
                    dast = 0;
                    dash = 0;
                    gvy = 0;
                    djmp = 0;
                }
                else if dash and (arrow==2)//Goto down air dash
                {   move = 27;
                    dast = 0;
                }
                else if dast <= 0//Return to previous state
                {   move = ptate;
                    dash=0;
                }
                else if (arrow==forward) or (arrow==forward+3)//Goto prepare forward air
                {   move = 18;
                    dast = 0;
                    dash = 0;
                }
                else if (arrow==backward) or (arrow==backward+3)//Goto prepare back air
                {   move = 21;
                    dast = 0;
                    dash = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Down air dash
    case 27:    if !grounded
                {   hspeed = 0;
                    vspeed = walk_sp[state];
                    dash--;//Dash until end duration
                }
                ////
                if grounded//Goto crouching
                {   move = 9;
                    dash = 0;
                }
                else if dash <= 0//Goto neutral jump
                {   move = 23;
                    gvy = walk_sp[23] + walk_sp[state];
                    dash = 0;
                    airborne = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Forward hop
    case 28:    if !grounded
                {   hspeed = walk_sp[state] * (forward-5);
                    vspeed = -walk_sp[30] + gvy;
                }
                ////
                if grounded//Goto neutral stand
                    move = 0;
                else if djmp and jump//Do a second jump
                {   if arrow == forward//Goto forward jump
                        move = 17;
                    else if arrow == backward//Goto back jump
                        move = 20;
                    else//Goto neutral jump
                        move = 23;
                    gvy = 0;
                    djmp = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Back hop
    case 29:    if !grounded
                {   hspeed = walk_sp[state] * (backward-5);
                    vspeed = -walk_sp[30] + gvy;
                }
                ////
                if grounded//Goto neutral stand
                    move = 0;
                else if djmp and jump//Do a second jump
                {   if arrow == forward//Goto forward jump
                        move = 17;
                    else if arrow == backward//Goto back jump
                        move = 20;
                    else//Goto neutral jump
                        move = 23;
                    gvy = 0;
                    djmp = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Neutral hop
    case 30:    if !grounded
                {   hspeed = 0;
                    vspeed = -walk_sp[state] + gvy;
                }
                ////
                if grounded//Goto neutral stand
                    move = 0;
                else if djmp and jump//Do a second jump
                {   if arrow == forward//Goto forward jump
                        move = 17;
                    else if arrow == backward//Goto back jump
                        move = 20;
                    else//Goto neutral jump
                        move = 23;
                    gvy = 0;
                    djmp = 0;
                }
                else if arrow == forward//Goto prepare forward jump
                {   move = 18;
                    ptate = state;
                }
                else if arrow == backward//Goto prepare back jump
                {   move = 21;
                    ptate = state;
                }
                else//Stay here
                    move = state;
                break;
    
    //Non-movement, safety net
    default:    move = 0;
}

//Prepare jump lag
state = move;
if (move==16) and (plag<0)
    plag = jlag;
move = 0;


#define BS_attacking

//Attack type
if (buffer_mtr>59) and attack
{   switch state
    {   //Standing grab/attack/sbecial
        case 0:     //
        case 1:     //GW
        case 2:     //GS
        case 3:     //B
        case 4:     //
        case 6:     //
        case 7:     if !((arrow==forward) or (arrow==forward+3))
                    {   if attack == 2
                        {   if shoulder == 1
                                move = 224;
                            else
                                move = 64;
                        }
                        else if attack == 3
                        {   if shoulder == 1
                                move = 232;
                            else
                                move = 72;
                        }
                        else if (attack==1) and goo
                            move = 192;
                    }
        //Tilt grab/attack/sbecial
                    else
                    {   dast = 0;
                        dash = 0;
                        if attack == 2
                        {   if shoulder == 1
                                move = 224;
                            else
                                move = 80;
                        }
                        else if attack == 3
                        {   if shoulder == 1
                                move = 232;
                            else
                                move = 88;
                        }
                        else if (attack==1) and goo
                            move = 200;
                    }
                    break;
        
        //Rushing attack
        case 5:     //
        case 8:     dash = 0;
                    if attack == 2
                        move = 96;
                    else if attack == 3
                        move = 104;
                    break;
        
        //Crouching attack/sbecial
        case 9:     if attack == 2
                        move = 112;
                    else if attack == 3
                        move = 120;
                    else if (attack==1) and goo
                        move = 208;
                    break;
        
        //Upper attack/sbecial
        case 10:    if attack == 2
                        move = 128;
                    else if attack == 3
                        move = 136;
                    else if (attack==1) and goo
                        move = 216;
                    break;
                    
        //Air attacks
        case 17:    //
        case 18:    //N
        case 20:    //F
        case 21:    //D
        case 23:    //
        case 24:    //
        case 25:    //
        case 26:    //
        case 28:    //
        case 29:    //
        case 30:    if attack == 2
                    {   if (arrow==backward) or (arrow==backward+3)
                        or (arrow==5)
                            move = 144;
                        else if (arrow==forward) or (arrow==forward+3)
                        or (arrow==8)
                            move = 160;
                        else//(1 2 3)
                            move = 176;
                    }
                    else if attack == 3
                    {   if (arrow==backward) or (arrow==backward+3)
                        or (arrow==5)
                            move = 152;
                        else if (arrow==forward) or (arrow==forward+3)
                        or (arrow==8)
                            move = 168;
                        else//(1 2 3)
                            move = 184;
                    }
                    break;
    }
    
    if move
    {   var cbox;
        cbox[0] = noone;
        cbox[1] = move;
        cbox[11] = 0;
        ds_list_add(abox,cbox);
        dask = 0;
    }
    if (move==192) or (move==200) or (move==208) or (move==216)
    {   gauge = floor(gauge*gauge / (300+40*goo));
        goo--;
    }
}

move = state;


#define BS_reacting

//Blocking and hit confirms
if oppose.hit_sty
{   sty = oppose.hit_sty&7;//3 bits(where attacks will hit): 1ground, 2low, 3mid, 4high, 5air
    boc = (oppose.hit_sty>>3)&3;//2 bits(if bounce should occur): 10wall, 01ground
    hit = (oppose.hit_sty>>5)&63;//type of attack
    unb = (oppose.hit_sty>>5)&64//1 bit(if unblockable)
    
    if !oppose.combo//First hit
    {   if grounded//Ground based
        {   if (arrow>=1) and (arrow<=3)//Defending low
            {   if (sty==1) or (sty==2) or (sty==3)//Block at ground, low, medium
                {   if unb
                    {   move = hit;
                        sty = 0;
                    }
                    else if shoulder == 1
                    {   if trig_ps//Ground perfect shield
                            move = 33;
                        else
                            move = 35;
                        sty = 1;
                    }
                    else if !(shoulder==2) and (arrow==backward-3)
                    {   move = 35;
                        sty = 0.5;
                    }
                    else
                    {   if (hit==38) or (hit==39)//Convert to hit low
                            move = hit + 2;
                        else
                            move = hit;
                        sty = 0;
                    }
                }
                else if sty == 4//Bypass at high
                {   if trig_ps and (shoulder==1)//Ground perfect shield
                    {   move = 33;
                        sty = 1;
                    }
                    else
                    {   if (hit==38) or (hit==39)//Convert to hit low
                            move = hit + 2;
                        else
                            move = hit;
                        sty = 0;
                    }
                }
                else//(sty==5) Miss at air
                    sty = -1;
            }
            ////
            else if (arrow>=4) and (arrow<=6)//Defending medium
            {   if (sty==1) or (sty==2)//Bypass at ground, low
                {   if unb
                    {   move = hit;
                        sty = 0;
                    }
                    else if trig_ps and (shoulder==1)//Ground perfect shield
                    {   move = 33;
                        sty = 1;
                    }
                    else
                    {   move = hit;
                        sty = 0;
                    }
                }
                else if (sty==3) or (sty==4)//Block at medium, high
                {   if shoulder == 1
                    {   if trig_ps//Ground perfect shield
                            move = 33;
                        else
                            move = 36;
                        sty = 1;
                    }
                    else if !(shoulder==2) and (arrow==backward-3)
                    {   move = 36;
                        sty = 0.5;
                    }
                    else
                    {   move = hit;
                        sty = 0;
                    }
                }
                else//(sty==5) Miss at air
                    sty = -1;
            }
            ////
            else//Defending high
            {   if (sty==1) or (sty==2) or (sty==3)//Bypass at ground, low, medium
                {   if unb
                    {   move = hit;
                        sty = 0;
                    }
                    else if trig_ps and (shoulder==1)//Ground perfect shield
                    {   move = 33;
                        sty = 1;
                    }
                    else
                    {   move = hit;
                        sty = 0;
                    }
                }
                else if sty == 4//Block at high
                {   if shoulder == 1
                    {   if trig_ps//Ground perfect shield
                            move = 33;
                        else
                            move = 37;
                        sty = 1;
                    }
                    else
                    {   move = hit;
                        sty = 0;
                    }
                }
                else//(sty==5) Miss at air
                    sty = -1;
            }
        }
        
        else//Air based
        {   if (sty>=2 and sty<=5)//Block at low, medium, high, air
            {   if unb
                {   move = hit;
                    sty = 0;
                }
                if trig_ps and (shoulder==1)//Air perfect shield
                {   move = 34;
                    sty = 1;
                }
                else
                {   if (hit==38) or (hit==39)//Convert to hit high
                        move = hit + 4;
                    else if hit == 44//Convert to hit high hard
                        move = hit - 1;
                    else if hit == 45//Convert to toss spin
                        move = hit + 4;
                    else
                        move = hit;
                    sty = 0;
                }
            }
            else//(sty==1) Miss at ground
                sty = -1;
        }
    }
    
    else//Continuing combo
    {   if (sty>=1 and sty<=4) and grounded//Ground based
        {   if (state==40 or state==41 or state==45) and (hit==38 or hit==39)//Convert to hit low
                move = hit + 2;
            else if (state==45) and (sty==1)//Convert to force lay
                move = state + 1;
            else
                move = hit;
            sty = 0;
        }
        else if (sty>=2 and sty<=5) and !grounded//Air based
        {   if (hit==38) or (hit==39)//Convert to hit high
                move = hit + 4;
            else if (hit==44)//Convert to hit high hard
                move = hit - 1;
            else if (hit==45)//Convert to toss spin
                move = hit + 4;
            else
                move = hit;
            sty = 0;
        }
        else
            sty = -1;
    }
    
    if sty >= 0//Confirm hit to self
    {   oppose.combo++;
        gvy = 0;
        if cancel != 1
        {   if !cancel
                cancel = 1;
            else
                cancel += 1;
        }
        hspeed = 0;
        vspeed = 0;
        if sty//?//FIX UP BEING LOW
        ////////////////
        {   if (hit==38) or (hit==39)
                brek = hit + 2;
            else
                brek = hit;
        }
    }
    else if rem.hit < 0//Deconfirm hit
    {   var cbox = oppose.abox[|-(rem.hit+1)];
        cbox[@10] = 0;
        if !is_undefined(oppose.abox[|-rem.hit])
        {   ds_list_delete(oppose.abox,-rem.hit);
            oppose.buffer_mtr = hsphit - 1;
        }
    }
    oppose.hit_sty = 0;
    hlag--;
}
state = move;

//Reaction flows
if (state>=32 and state<64) switch state
{   //Hit lag
    case 32:    if !hlag//Return to previous state
                {   move = utate;
                    if sty > 0
                    {   hspeed = oppose.blocks[htate,2] * (backward-5);
                        vspeed = 0;
                    }
                    else
                    {   hspeed = hsphit;
                        vspeed = vsphit;
                        //hsphit = 0;
                        //vsphit = 0;
                    }
                }
                else//Stay here
                {   hlag--;
                    move = state;
                }
                break;
                
    //Blockstun low
    case 35:    //
    //Hit low light
    case 40:    //
    //Hit low hard
    case 41:    //
    //Hit force down
    case 45:    if hlag < 0//Goto hit lag
                {   move = 32;
                    utate = state;
                    hlag = oppose.damage[htate,2];
                }
                else if buffer_mtr > 59//Goto crouching
                {   move = 9;
                    gvydam = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Blockstun medium
    case 36:    //
    //Hit medium light
    case 38:    //
    //Hit medium hard
    case 39:    //
    //Hit force up
    case 44:    if hlag < 0//Goto hit lag
                {   move = 32;
                    utate = state;
                    hlag = oppose.damage[htate,2];
                }
                else if buffer_mtr > 59//Goto neutral stand
                {   move = 0;
                    gvydam = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Blockstun high
    case 37:    if hlag < 0//Goto hit lag
                {   move = 32;
                    utate = state;
                    hlag = oppose.damage[htate,2];
                }
                else if buffer_mtr > 59//Goto looking up
                {   move = 10;
                    gvydam = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Hit high light
    case 42:    if hlag < 0//Goto hit lag
                {   move = 32;
                    utate = state;
                    hlag = oppose.damage[htate,2];
                }
                else
                {   if !grounded
                    {   hspeed = 1 * (backward-5);
                        vspeed = -1 + gvy;
                    }
                    ////
                    if grounded//Goto tech lay
                    {   move = 51;
                        utate = state;
                    }
                    else if buffer_mtr > 59//Goto neutral jump
                    {   move = 23;
                        airborne = 1;
                        gvydam = 0;
                    }
                    else//Stay here
                        move = state;
                }
                break;
                
    //Hit high hard
    case 43:    if hlag < 0//Goto hit lag
                {   move = 32;
                    utate = state;
                    hlag = oppose.damage[htate,2];
                }
                else
                {   if !grounded
                    {   hspeed = 2 * (backward-5);
                        vspeed = -2 + gvy;
                    }
                    ////
                    if grounded//Goto tech lay
                    {   move = 51;
                        utate = state;
                    }
                    else if buffer_mtr > 59//Goto tech air neutral
                    {   move = 59;
                        buffer_mtr = 50;
                    }
                    else//Stay here
                        move = state;
                }
                break;
                
    //Hit force lay
    //FIX///////////////////NOTHING IN 51
    case 46:    if hlag < 0//Goto hit lag
                {   move = 32;
                    utate = state;
                    hlag = oppose.damage[htate,2];
                }
                else if buffer_mtr > 49//Goto tech lay
                {   move = 51;
                    utate = state;
                }
                else//Stay here
                    move = state;
                break;
                
    //Toss ground
    case 47:    //
    //Toss spin
    case 49:    if hlag < 0//Goto hit lag
                {   move = 32;
                    utate = state;
                    hlag = oppose.damage[htate,2];
                }
                else
                {   if !grounded
                        vspeed += gvydam;
                    ////
                    if grounded//Goto tech lay
                    {   move = 51;
                        utate = state;
                    }
                    else//Stay here
                        move = state;
                }
                break;
                
    //Toss air
    case 48:    //
    //Toss circle
    case 50:    if hlag < 0//Goto hit lag
                {   move = 32;
                    utate = state;
                    hlag = oppose.damage[htate,2];
                }
                else
                {   if !grounded
                        vspeed += gvydam;
                    ////
                    if grounded//Goto tech lay
                    {   move = 51;
                        utate = state;
                    }
                    else if (buffer_mtr>59) and jump//Air-recoverable
                    {   if (arrow==forward+3) or (arrow==forward-3)//Goto tech air forward
                        or (arrow==forward)
                            move = 60;
                        else if (arrow==backward+3) or (arrow==backward-3)//Goto tech air backward
                        or (arrow==backward)
                            move = 61;
                        else//Goto tech air neutral
                            move = 59;
                        buffer_mtr = 50;
                        gvy = 0;
                        //gvydam = 0;
                    }
                    else//Stay here
                        move = state;
                }
                break;
                
    //Tech lay
    //FIX////////////////////SOME BOUNCE AND LAY STAY DOWN
    case 51:    if (utate==47) or (utate==50) or (utate==52) or (utate==53)//Recoverable
                {   if shoulder == 1
                    {   if (arrow==forward+3) or (arrow==forward-3)//Goto tech ground forward
                        or (arrow==forward)
                            move = 57;
                        else if (arrow==backward+3) or (arrow==backward-3)//Goto tech ground backward
                        or (arrow==backward)
                            move = 58;
                        else//Goto tech ground neutral
                            move = 56;
                        buffer_mtr = 50;
                    }
                    else if utate != 52
                    {   if boc&1//Goto bounce floor
                        {   move = 54;
                            vspeed = vspdam;
                        }
                        else//Goto bounce drag
                            move = 55;
                    }
                    else//Stay here, missed recover
                    {   move = state;
                        utate = state;
                        //gvydam = 0;
                    }
                }
                else if utate == 48//Non-recoverable
                {   if boc&1//Goto bounce floor
                    {   move = 54;
                        vspeed = vspdam;
                    }
                    else//Goto bounce drag
                        move = 55;
                }
                else if buffer_mtr > 59//Now recoverable
                {   if utate == 51
                    {   if (arrow==forward+3) or (arrow==forward-3)//Goto tech ground forward
                        or (arrow==forward)
                            move = 57;
                        else if (arrow==backward+3) or (arrow==backward-3)//Goto tech ground backward
                        or (arrow==backward)
                            move = 58;
                        else if (shoulder==1) or jump or attack//Goto tech ground neutral
                            move = 56;
                        else//Stay here
                        {   move = state;
                            utate = state;
                            //gvydam = 0;
                        }
                    }
                    else//(u42 u43)Forced tech ground neutral
                        move = 56;
                    if move != state
                        buffer_mtr = 50;
                }
                else//(u46 u49 u54 u55)Stay here, cannot recover yet
                {   move = state;
                    if !(utate==42) and !(utate==43)
                        utate = state;
                    hspeed = 0;
                    //gvydam = 0;
                }
                break;
                
    //Bounce trip
    case 52:    if !grounded
                    vspeed += gvydam;
                ////
                if grounded//Goto tech lay
                {   move = 51;
                    utate = state;
                }
                break;
                
    //Bounce wall
    case 53:    if !grounded
                    vspeed += gvydam;
                ////
                if grounded//Goto tech lay
                {   move = 51;
                    utate = state;
                }
                else if (buffer_mtr>59) and jump//Air-recoverable
                {   if (arrow==forward+3) or (arrow==forward-3)//Goto tech air forward
                    or (arrow==forward)
                        move = 60;
                    else if (arrow==backward+3) or (arrow==backward-3)//Goto tech air backward
                    or (arrow==backward)
                        move = 61;
                    else//Goto tech air neutral
                        move = 59;
                    buffer_mtr = 50;
                    gvy = 0;
                    //gvydam = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Bounce floor
    case 54:    if !grounded
                    vspeed += gvydam;
                ////
                if grounded//Goto tech lay
                {   move = 51;
                    utate = state;
                }
                else if jump//Air-recoverable
                {   if (arrow==forward+3) or (arrow==forward-3)//Goto tech air forward
                    or (arrow==forward)
                        move = 60;
                    else if (arrow==backward+3) or (arrow==backward-3)//Goto tech air backward
                    or (arrow==backward)
                        move = 61;
                    else//Goto tech air neutral
                        move = 59;
                    buffer_mtr = 50;
                    gvy = 0;
                    //gvydam = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Bounce drag
    case 55:    if buffer_mtr > 49//Goto tech lay
                {   move = 51;
                    utate = state;
                }
                break;
                
    //Tech ground neutral
    case 56:    hspeed = 0;
                vspeed = 0;
                ////
                if buffer_mtr > 59//Goto neutral stand
                {   move = 0;
                    gvydam = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Tech ground forward
    case 57:    hspeed = walk_sp[state] * (forward-5);
                vspeed = 0;
                ////
                if buffer_mtr > 59//Goto crouching
                {   move = 9;
                    gvydam = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Tech ground backward
    case 58:    hspeed = walk_sp[state] * (backward-5);
                vspeed = 0;
                ////
                if buffer_mtr > 59//Goto crouching
                {   move = 9;
                    gvydam = 0;
                }
                else//Stay here
                    move = state;
                break;
                
    //Tech air neutral
    case 59:    hspeed = 2 * (backward-5);
                vspeed = -10 * grav;
                ////
                if buffer_mtr > 59//Goto neutral jump
                {   move = 23;
                    airborne = 1;
                    gvydam = 0;
                    heldlr = 0;
                    //vspeed = gvy/2;
                }
                else//Stay here
                    move = state;
                break;
                
    //Tech air forward
    case 60:    hspeed = walk_sp[state] * (forward-5);
                vspeed = -10 * grav;
                ////
                if buffer_mtr > 59//Goto neutral jump
                {   move = 23;
                    airborne = 1;
                    gvydam = 0;
                    heldlr = 1;
                    //vspeed = gvy/2;
                }
                else//Stay here
                    move = state;
                break;
                
    //Tech air backward
    case 61:    hspeed = walk_sp[state] * (backward-5);
                vspeed = -10 * grav;
                ////
                if buffer_mtr > 59//Goto neutral jump
                {   move = 23;
                    airborne = 1;
                    gvydam = 0;
                    heldlr = 1;
                    //vspeed = gvy/2;
                }
                else//Stay here
                    move = state;
                break;
                
    //Unique reaction
    case 62:    hspeed = 0;
                vspeed = 0;
                ////
                buffer_mtr -= 1;
                move = state;
                break;
}

state = move;


#define BS_cleanup

var nbox = argument0;
if is_array(nbox)
{   if instance_exists(hbox) and !hbox.visible//Remove canceled attacks
    {   cbox = 0;
        ds_list_delete(abox,i);
        with hbox instance_destroy();
    }
    else
    {   if nbox[1]//Add new attacks
        {   nbox[0] = noone;
            nbox[11] = 0;
            if !nbox[2]
                buffer_mtr = 58;
            cancel = 2;
            ds_list_add(abox,nbox);
        }
        if frame == 6//Remove old attacks
        {   cbox = 0;
            ds_list_delete(abox,i);
        }
        else//Update current attacks
        {   cbox[2] = frame;
            cbox[3] = buffer_af;
            cbox[4] = htx;
            cbox[5] = hty;
            cbox[6] = hzx;
            cbox[7] = hzy;
            cbox[8] = s_part;
            cbox[9] = t_part;
            cbox[10] = hfirm;
        }
    }
}

else
{   //Break checking
    if abs(dask)
    {   hspeed = dask;
        vspeed = 0;
        //lifted = 0;//?
    }
    
    //Wall checking
    if walled
    {   if hspeed*(walled-2) <= 0
            hspeed = 0;
        else
            x += (walled-2);
    }
}

hrbx.x = x + hspeed;
hrbx.y = y + vspeed;
