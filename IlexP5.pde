import processing.opengl.*;
import processing.pdf.*;
import controlP5.*;
ControlP5 cp5;
Group g1;
RadioButton rMotif, rColor;
Slider cg;
JSONObject data;


int cols, rows;
int grille = 20;
int w = 1800;
int h = 1800;
float flying = 0;
float rotX = -PI;
float rotY = PI;
float amplitude = 10;
float vitesse = 20;
float temperature;
float[][] terrain;
int motif = 0;
int contour = 1;

int bgMode;
int bgColor = color(100);

//météo
String ville = "Lyon";
int tmp;
int dataColor;


boolean dosave=false;
boolean play=true;
boolean rotable=true;
boolean dataMode = true;


void setup() {
    size(1000, 1000, OPENGL);
    
    //mode couleur
    bgMode = bgColor;
    
  // contrôles
  cp5 = new ControlP5(this);
  
  g1 = cp5.addGroup("g1")
    .setPosition(20,20)
    .setBackgroundHeight(120)
    .setHeight(0)
    .setWidth(width-40)
    .hideBar() 
    .hideArrow() 
    ;
  
  //Amplitude et vitesse
     cg = cp5.addSlider("grille")
     .setPosition(30,30)
     .setSize(200,20)
     .setRange(10,100)
     .setValue(20)
     .setGroup(g1)
     ;
     
    cp5.addSlider("contour")
     .setPosition(30,60)
     .setSize(200,20)
     .setRange(1,10)
     .setValue(1)
     .setNumberOfTickMarks(10)
     .setGroup(g1)
     ;
     
    cp5.addSlider("vitesse")
     .setPosition(260,30)
     .setSize(200,20)
     .setRange(0,100)
     .setValue(10)
     .setGroup(g1)
     ;
  
      cp5.addSlider("amplitude")
     .setPosition(260,60)
     .setSize(200,20)
     .setRange(0,100)
     .setValue(20)
     .setGroup(g1)
     ;
     
     rMotif = cp5.addRadioButton("motif")
     .setPosition(490,30)
     .setSize(50,15)
     .setColorActive(color(255))
     .addItem("Points",0)
     .addItem("Lignes",1)
     .addItem("Croix",2)
     .setGroup(g1)
     ;
     
      rColor = cp5.addRadioButton("bgColor")
     .setPosition(590,30)
     .setSize(50,15)
     .setColorActive(color(255))
     .addItem("Rouge",1)
     .addItem("Vert",2)
     .addItem("Bleu",3)
     .addItem("Gris",4)
     .addItem("Noir",5)
     .setGroup(g1)
     ;
     
      cp5.addToggle("dataMode")
     .setPosition(720,30)
     .setSize(50,20)
     .setValue(false)
     .setMode(ControlP5.SWITCH)
     .setGroup(g1)
     ;
     
      cp5.addTextfield("ville")
     .setPosition(790,30)
     .setSize(100,20)
     .setValue("Lyon")
     .setGroup(g1)
     ;
     
     cp5.addBang("Ok")
     .setPosition(900, 30)
     .setSize(30, 20)
     .setGroup(g1)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;    



  cp5.getController("grille").getValueLabel().align(ControlP5.LEFT, ControlP5.CENTER).setPaddingX(5);
  cp5.getController("grille").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(5);
  cp5.getController("vitesse").getValueLabel().align(ControlP5.LEFT, ControlP5.CENTER).setPaddingX(5);
  cp5.getController("vitesse").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(5);
  cp5.getController("amplitude").getValueLabel().align(ControlP5.LEFT, ControlP5.CENTER).setPaddingX(5);
  cp5.getController("amplitude").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(5);
  cp5.getController("contour").getValueLabel().align(ControlP5.LEFT, ControlP5.CENTER).setPaddingX(5);
  cp5.getController("contour").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(5);
  
  // Création du paysage
  createTerrain();  
}

void createTerrain(){
    cols = w / grille;
  rows = h/ grille;
  terrain = new float[cols][rows];
}

void getDatas(){
    // Mode data  
    data = loadJSONObject("https://api.apixu.com/v1/current.json?key=549f1310b0a04599b1b135645171209&q="+ville);
    JSONObject datas = data.getJSONObject("current");
    tmp = datas.getInt("temp_c");
    dataColor = color(tmp*10,0,255-tmp*10);
    println(ville+" : "+tmp+"°C");
}

void draw() {

  //pdf
    if(dosave) {
    // set up PGraphicsPDF for use with beginRaw()
    PGraphicsPDF pdf = (PGraphicsPDF)beginRaw(PDF, "#########.pdf"); 

    // set default Illustrator stroke styles and paint background rect.
    pdf.strokeJoin(MITER);
    pdf.strokeCap(SQUARE);
    pdf.noFill();
    pdf.noStroke();
    pdf.rect(0,0, width,height);
  }
  
  if(play){
    flying -= vitesse/2/4000;
  }

  float yoff = flying;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      terrain[x][y] = map(noise(xoff, yoff), 0, 1, -amplitude*10, amplitude*10);
      xoff += 0.02;
    }
    yoff += 0.01;
    
  }
  background(bgMode);
  stroke(255);
  noFill();
  
  //vérifier que les contrôles ne sont pas actifs
  if(cp5.isMouseOver()){
    rotable = false;
  }else{
    rotable = true;
  }

  pushMatrix();
  translate(width/2, height/2+50);
  rotateX(PI/2-rotX);
  rotateZ(PI/2-rotY);
  if(play){
    if ((mousePressed) && (rotable)) {
        rotX += (pmouseY-mouseY)*.01;
        rotY += (pmouseX-mouseX)*-.01; 
    }
  }
  translate(-w/2, -h/2);
  for (int y = 0; y < rows-1; y++) {

  // Type 1
  if(motif == 0){
    beginShape(POINTS);
    strokeWeight(contour*2);
  }
  
  // Type 2 et 3
  else if(motif == 1 || motif == 2){
    beginShape(LINES);
    strokeWeight(contour);
  }
  
    for (int x = 0; x < cols; x++) {
      if(motif == 0){vertex(x*grille, y*grille, terrain[x][y]);}
      else if(motif == 1){
        vertex(x*grille, y*grille, terrain[x][y]);
        vertex(x*grille, y*grille, terrain[x][y]+30);
      }
      else if(motif == 2){
        vertex(x*grille, y*grille-5, terrain[x][y]);
        vertex(x*grille, y*grille+5, terrain[x][y]);
        vertex(x*grille-5, y*grille, terrain[x][y]);
        vertex(x*grille+5, y*grille, terrain[x][y]);
      }
    }
    endShape();
  }
popMatrix();

  if(dosave) {
    endRaw();
    dosave=false;
  }
}

void keyPressed() {
  if(cp5.get(Textfield.class,"ville").isActive()==false){
   // pdf
  if (key == 's') { 
    dosave=true;
  }
  
  // png
  else if(key == 'i'){
    saveFrame("######.png");
  }
  
  // pause
  else if(key == 'p'){
    play=!play;
  }
  
  // masquer contrôles
  else if(key == 'c'){
    if(g1.isVisible() == true){
      g1.hide();
    }else{
      g1.show();
    }
  }
  }
}

void controlEvent(ControlEvent theEvent) {
  if(theEvent.isFrom(rMotif)) {
    motif = int(theEvent.getGroup().getValue());
  }

  //couleurs
  if(theEvent.isFrom(rColor)) {
    if(theEvent.getGroup().getValue()==1){
    bgColor = color(255,0,0);
    }else if(theEvent.getGroup().getValue()==2){
    bgColor = color(50,150,0);
    }else if(theEvent.getGroup().getValue()==3){
    bgColor = color(0,0,255);
    }else if(theEvent.getGroup().getValue()==4){
    bgColor = color(100);
    }else if(theEvent.getGroup().getValue()==5){
    bgColor = color(0);
    }
    if(!dataMode){
    bgMode = bgColor;
    }
  }
}

void dataMode(boolean theFlag) {
  if(theFlag==true) {
    bgMode = bgColor;
    dataMode = false;
  }else{
    getDatas();
    bgMode = dataColor;
    dataMode = true;
  }
}

void Ok() {
  ville = cp5.get(Textfield.class,"ville").getText();
  getDatas();
  bgMode = dataColor;
}