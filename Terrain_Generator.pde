import controlP5.*;
ControlP5  cp5;




//these update each time the generate button is pressed
boolean mouse_over = false;
boolean use_color = true;
boolean use_stroke = false;
boolean use_blend = false;
boolean generate_bool = false;
String loaded_file;
float height_modifier = 0;
float snow_threshold = 1.0;
int rows_var = 30;
int cols_var = 30;
float terrain_size = 30;

//whatever is stored here after the generate button is pressed will be printed to the screen
ArrayList<PVector> vData = new ArrayList<PVector>(); 
ArrayList<Integer> tData = new ArrayList<Integer>();




float cameraX = 0, cameraY = 180, cameraZ = 75;
float eyeX = 0, eyeY = 0, eyeZ = 0;
Camera cam = new Camera();



// All sliders the UI will use:

Slider rows,
       columns, 
       gridSize,
       vHeight, 
       snow;

Button generate;

Textfield file_to_load;

Toggle strokeTog, colorTog, blendTog;


boolean mouse_dragged = false;

void setup()
{
  size(1200, 800, P3D);
  cp5 = new ControlP5(this);
  // UI elements:
  
  //row slider:
  rows = cp5.addSlider("row_slider");
  rows.setCaptionLabel("rows");
  rows.setPosition(10,10);
  rows.setRange(1, 100);
  rows.setValue(30);
  rows.getValueLabel().setSize(15);
  rows.setDecimalPrecision(0);
  
  //columns slider:
  columns = cp5.addSlider("col_slider");
  columns.setCaptionLabel("columns");
  columns.setPosition(10, 30);
  columns.setValue(30);
  columns.setRange(1,100);
  columns.getValueLabel().setSize(15);
  columns.setDecimalPrecision(0);
  
  //grid size (terrain size) slider:
  gridSize = cp5.addSlider("grid_slider");
  gridSize.setCaptionLabel("Terrain size");
  gridSize.setPosition(10, 50);
  gridSize.setRange(20,50);
  gridSize.setValue(30);
  gridSize.getValueLabel().setSize(15);
  gridSize.setDecimalPrecision(2);
  
  //generate button:
  generate = cp5.addButton("toggleStart");
  generate.setCaptionLabel("generate");
  generate.setPosition(10, 70);
  generate.setSize(70,20);
  
  //load from file textbox:
  file_to_load = cp5.addTextfield("file_textbox");
  file_to_load.setSize(120,20);
  file_to_load.setPosition(10, 100);
  file_to_load.setCaptionLabel("Load from file");
  
  //stroke toggle
  strokeTog = cp5.addToggle("strokeTog");
  strokeTog.setSize(50, 20);
  strokeTog.setValue(1);
  strokeTog.setPosition(200, 10);
  strokeTog.setCaptionLabel("stroke");
  
  //color toggle
  colorTog = cp5.addToggle("colorTog");
  colorTog.setSize(50,20);
  colorTog.setPosition(270, 10);
  colorTog.setCaptionLabel("color");
  
  //blend toggle
  blendTog = cp5.addToggle("blendTog");
  blendTog.setSize(50,20);
  blendTog.setPosition(340, 10);
  blendTog.setCaptionLabel("blend");
  
  //height modifier slider:
  vHeight = cp5.addSlider("height_slider");
  vHeight.setPosition(200, 50);
  vHeight.setCaptionLabel("height modifier");
  vHeight.setRange(-5.0, 5.0);
  vHeight.setValue(2.0);
  vHeight.setDecimalPrecision(2);
  
  //snow modifier slider:
  snow = cp5.addSlider("snow_slider");
  snow.setPosition(200, 80);
  snow.setCaptionLabel("snow threshold");
  snow.setRange(1, 5);
  snow.setDecimalPrecision(2);
}


void draw()
{
  background(0);
  float deltaX = 0;
  float deltaY= 0; 
  check_mouse_over();
  perspective(radians(60), (float)width/height, 0.1, 100);
  if(mouse_dragged == true)
  {
     deltaX = mouseX - pmouseX;
     deltaY = mouseY - pmouseY;
  }
  
  cam.Update_new(deltaX, deltaY);
  //draw_grid();
  fill(255,200,155);
  /*
  if(vData.size()>0 && tData.size()>0)
  {
     draw_to_screen();
    
  }
  */
  draw_to_screen();
 //cam.Update_new(deltaX, deltaY);
  
  //reset perpective and camera so control p5 will render
  perspective();
  camera();
}

void check_mouse_over()
{
  if(cp5.isMouseOver())
     mouse_over = true;
  else
    mouse_over = false;
}

void mouseDragged(MouseEvent event)
{
  mouse_dragged = true;

}

void mouseWheel(MouseEvent event)
{
    float e = event.getCount();
   // println(e);
    cam.Zoom(e);
}


void toggleStart(boolean val)
{
  //println("val: " + val);
  getInputs();
  //need to create a base grid with the new values
  //then draw to the screen
  draw_base_grid();
  drawTriangles();
  PImage pic = loadImage(loaded_file);
  if(pic != null)
  {
    //deal with file
    dealwithFile();
   //println("file is loaded, dealing with it");
  }

}

//need a function to get all the values from the UI inputs
void getInputs()
{
  use_color = boolean((int)colorTog.getValue());
  use_stroke = boolean((int)strokeTog.getValue());
  use_blend = boolean((int)blendTog.getValue());
  loaded_file = file_to_load.getText();
  loaded_file = loaded_file + ".png";
  height_modifier = vHeight.getValue();
  snow_threshold = snow.getValue();
  rows_var = (int)rows.getValue();
  cols_var = (int)columns.getValue();
  terrain_size = gridSize.getValue();
  
}

boolean getBoolean(int temp)
{
  if(temp == 1)
    return true;
  return false;
}

void draw_base_grid()
{
   ArrayList<PVector> temp_vertex = new ArrayList<PVector>(); 
  
  float row_start = -terrain_size/2;
  float col_start = -terrain_size/2;
  float row_end = terrain_size/2;
  float col_end = terrain_size/2;
  float row_step = (terrain_size/rows_var);
  float col_step = (terrain_size/(cols_var));
  int colP = cols_var;
  for(int i = 0; i < rows_var+1; i++)
  {
    
    for(int j = 0; j < colP+1; j++)
    {
      //need an x position
      // y position stays 0
      //need a z position
      //if(col_start <= col_end)
      //{
        float z = col_start;
        //row_start += row_step; //increment after getting value
        float x = row_start;
        col_start += col_step;
        //row_start+=row_step;
        //col_start+= col_step;
        PVector temp = new PVector(x, 0, z);
        temp_vertex.add(temp);
      //} 
    }
    row_start += row_step;
    col_start = -terrain_size/2;
    //col_start+=col_step;
  }
  vData = temp_vertex;
  for(int i = 0; i < temp_vertex.size(); i++)
  {
    vData.set(i, temp_vertex.get(i));
  }
  //dealwithFile(temp_vertex); 
}


void drawTriangles()
{
  fill(255);
 ArrayList<Integer> triangles = new ArrayList<Integer>(); //stores each traingle with all 3 vertex in it
 int startIndex = 0;
 for(int i = 0; i < rows_var; i++)
 {
   
   for(int j = 0; j < cols_var; j++)
   {
     startIndex = i * (cols_var+1) + j; //to get the full : startIndex = row (i) * verticesInARow (rows_float+1) + currentColumn (j)
    //top triangles:
    int temp_one = startIndex; //startingIndex
    int temp_two = startIndex + 1; //startingIndex +1
    int temp_three = startIndex + cols_var + 1;  //startingIndex + verticies in a row (rows_float + 1)
    
    triangles.add(temp_one);
    triangles.add(temp_two);
    triangles.add(temp_three);
    
    //bottom triangles
    int temp_four = startIndex+1; //startingIndex + 1;
    int temp_five = startIndex + cols_var+2; //startingIndex + verticies in a row (rows_float + 1) + 1
    int temp_six = startIndex + cols_var+1; //startingIndex + verticies in a row
    
    triangles.add(temp_four);
    triangles.add(temp_five);
    triangles.add(temp_six);
   }
   
   int start2index = (rows_var-1) * (cols_var+1) + (cols_var-1);
   int temp_one = start2index;
   int temp_two = start2index +1;
   int temp_three = start2index + cols_var+1;
   
   int temp_four = start2index + 1;
   int temp_five = start2index + cols_var+2;
   int temp_six = start2index + cols_var+1;
    triangles.add(temp_one);
    triangles.add(temp_two);
    triangles.add(temp_three);
    triangles.add(temp_four);
    triangles.add(temp_five);
    triangles.add(temp_six);
    
 }
 tData = triangles;

}


void draw_to_screen()
{
  beginShape(TRIANGLES);
  //fill(45, 45, 1);
  for(int i = 0; i < tData.size(); i++)
  {
    if(use_color == true)
    {
      //from project document
      color snow = color(255, 255, 255);
      color grass = color(143, 170, 64); 
      color rock = color(135, 135, 135); 
      color dirt = color(160, 126, 84); 
      color water = color(0, 75, 200);
      
      float relativeHeight = abs(vData.get(tData.get(i)).y)*height_modifier / -snow_threshold;
      relativeHeight = abs(relativeHeight/10);
      if( relativeHeight >0.8)
      {
        
        if(use_blend == true)
        {
          float ratio = (relativeHeight-0.8f)/0.2f;
          color temp = lerpColor(rock, snow, ratio);
          fill(temp);
        }
        else
          fill(255,255,255);
      
      }
      else if(relativeHeight <= 0.8 && relativeHeight >0.4)
      {
        if(use_blend == true)
        {
          float ratio = (relativeHeight-0.4f)/0.2f;
          color temp = lerpColor(grass, rock, ratio);
          fill(temp);
        }
        else
          fill(135, 135, 135);
      }
      else if(relativeHeight <= 0.4 && relativeHeight >0.2)
      {
        if(use_blend == true)
        {
          float ratio = (relativeHeight-0.2)/0.2f;
          color temp = lerpColor(dirt, grass, ratio);
          fill(temp);
        }
        else
          fill(143, 170, 64);
      }
      else
      {
        if(use_blend == true)
        {
          float ratio = (relativeHeight)/0.2f;
          color temp = lerpColor(water, dirt, ratio);
          fill(temp);
        }
        else
        fill(0, 75, 200);
      }
    }
    else
      fill(255,255,255);
    if(use_stroke == false)
      noStroke();
    else
      stroke(0);
    vertex(vData.get(tData.get(i)).x, -vData.get(tData.get(i)).y, vData.get(tData.get(i)).z);   
    
  }
  endShape(); 
  
}


void dealwithFile()
{
  PImage picture = loadImage(loaded_file);
  if(picture != null)
  {
    //image(picture, 0,0);
    for(int i = 0; i <= rows_var; i++)
    {
      for(int j = 0 ; j <= cols_var; j++)
      {
        float x_index = map(j, 0, cols_var+1, 0, picture.width);
        float y_index = map(i, 0, rows_var+1, 0, picture.height);
        float col = red(picture.get((int)x_index, (int)y_index));
        float heightFromColor = map(col, 0, 255, 0, 1.0f);
       // float heightFromColor = map(col, 0, 255, 0, 10);
        int vertex_index = i * (cols_var +1) + j;
        
        PVector temp;
        temp = vData.get(vertex_index);
        temp.z = -vData.get(vertex_index).z;
        temp.y = height_modifier*heightFromColor;
        vData.set(vertex_index, temp);        
        //vertexData.set(vertex_index, temp);
      }
    }
   
  }
}
