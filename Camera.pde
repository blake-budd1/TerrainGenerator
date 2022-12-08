class Camera
{
  //stores camera x,y,z
  PVector camera_position;

  PVector obj_position;
  
  float phi = 0;
  float theta = 0;
  
  //need a radius variable:
  float radius = 75; //starts at 50
  
  int curr_target = 0;
  
  //constructor:
  Camera()
  {
    camera_position = new PVector(0, 180, 75);
    obj_position = new PVector(0,0,0);
    //targets.add(obj_position);
  }
  
 
  
  void Zoom(float scale)
  {
     if(scale > 0 && scale + radius < 1000)
     {
       //means zooming in 
       radius = radius + scale;
     }
     else if(scale < 0 && scale + radius > 30)
     {
       radius = radius + scale;
     }
  }
  
  
  void Update_new(float deltaX, float deltaY)
  {

       if(cp5.isMouseOver())
      {
      
       camera(camera_position.x, camera_position.y, camera_position.z,
            0,0,0,
            0, 1, 0);
          
       perspective(radians(50f), width/(float)height, 0.1, 1000);
       return;
     
      }
     else  //using mouseDragged() to get previous and new position
     {
        float tempX, tempY, tempZ; //gets the derived value from the mouse positions
       
        
        float deltaX_new = deltaX*0.15f;
     
        float deltaY_new = deltaY*0.15f;
        
        phi += deltaX_new;
        if(theta + deltaX_new >= 179)
        {
          theta = 1;
        }
        else if(theta + deltaX_new < 1)
           theta = 1;
        else
          theta += deltaY_new;
          
       
       
       tempX = ( radius * cos(radians(phi)) * sin(radians(theta)));
       tempY = ( radius * cos(radians(theta)));
       tempZ = ( radius * sin(radians(theta)) * sin(radians(phi)));
       

        camera_position = new PVector(tempX, tempY, tempZ);
        
     }
     
     
     camera(camera_position.x, camera_position.y, camera_position.z,
            0,0,0,
            0, 1, 0);
            
     perspective(radians(50f), width/(float)height, 0.1, 1000); // only need to call once
     mouse_dragged = false;
  }



  
  
};
