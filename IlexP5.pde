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
int w = 2000;
int h = 2000;
float flying = 0;
float rotX = -PI;
float rotY = PI;
float amplitude = 10;
float vitesse = 20;
float temperature;
float[][] terrain;
int motif = 0;
int contour = 1;
float tz;

int bgMode;
int bgColor = color(100);

//météo
String ville = "Lyon";
int tmp;
float dataVent;
int dataColor;
float windVitesseMode;
float windAmpMode;


// Booléens
boolean dosave=false;
boolean play=true;
boolean rotable=true;
boolean dataMode = false;


void setup() {
    size(1000, 1000, OPENGL);
    
    //mode couleur
    bgMode = bgColor;
    windVitesseMode = vitesse;
    windAmpMode = amplitude;
    
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
     .addItem("Vortex",3)
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
     .setValue(true) // = False...
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

// Fonction de création du paysage
void createTerrain(){
  cols = w / grille;
  rows = h / grille;
  terrain = new float[cols][rows];
}

// Fonction pour récupérer les données météo sur l'API apixu
void getDatas(){
    // Mode data  
    data = loadJSONObject("https://api.apixu.com/v1/current.json?key=549f1310b0a04599b1b135645171209&q="+ville);
    JSONObject datas = data.getJSONObject("current");
    tmp = datas.getInt("temp_c");
    dataVent = datas.getInt("wind_kph");
    dataColor = color(tmp*10,0,255-tmp*10);
    println(ville+" : "+tmp+"°C / "+dataVent+" km/h");
}

// Boucle principale
void draw() {
    // Export pdf
    if(dosave) {
    // set up PGraphicsPDF for use with beginRaw()
    PGraphicsPDF pdf = (PGraphicsPDF)beginRaw(PDF, "#########.pdf"); 

    // Options export pdf
    pdf.strokeJoin(MITER);
    pdf.strokeCap(SQUARE);
    pdf.noFill();
    pdf.noStroke();
    pdf.rect(0,0, width,height);
  }
  
  // Mode manuel ou mode data
  if(dataMode == false){
    windVitesseMode = vitesse;
    windAmpMode = amplitude;
  }
  
  // Mode lecture
  if(play){
    flying -= windVitesseMode/2/4000;
  }

  // Calcul des coordonnées de la grille
  float yoff = flying;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      terrain[x][y] = map(noise(xoff, yoff), 0, 1, -windAmpMode*10, windAmpMode*10);
      xoff += 0.02;
    }
    yoff += 0.01;
    
  }
  
  // Couleur de fond et options graphiques
  background(bgMode);
  // Couleur des éléments graphiques (blancs)
  stroke(255);
  noFill();
  
  // Vérifier que les contrôles ne sont pas actifs
  if(cp5.isMouseOver()){
    rotable = false;
  }else{
    rotable = true;
  }
  
  // Formes
  pushMatrix();
  translate(width/2, height/2, tz);
  
  // Rotation 3D
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

  // Motifs
 
  // Type 1
  if(motif == 0 || motif == 3){
    beginShape(POINTS);
    strokeWeight(contour*2);
  }
  
  // Type 2 et 3
  else if(motif == 1 || motif == 2){
    beginShape(LINES);
    strokeWeight(contour);
  }
  
    for (int x = 0; x < cols; x++) {
      // Points
      if(motif == 0){
        vertex(x*grille, y*grille, terrain[x][y]);
      }
      // Lignes
      else if(motif == 1){
        vertex(x*grille, y*grille, terrain[x][y]);
        vertex(x*grille, y*grille, terrain[x][y]+50);
      }
      // Croix
      else if(motif == 2){
        vertex(x*grille, y*grille-5, terrain[x][y]);
        vertex(x*grille, y*grille+5, terrain[x][y]);
        vertex(x*grille-5, y*grille, terrain[x][y]);
        vertex(x*grille+5, y*grille, terrain[x][y]);
      }
      // Vortex
      else if(motif == 3){
        vertex(x*grille, y*grille, terrain[x][y]);
        rotateX(0.001);
        rotateY(0.001);
        rotateZ(0.001);
      } 
    }
    endShape();
  }
popMatrix();

  if(dosave) {
    endRaw();
    dosave=false;
  }
  
  // hack toggle
  if(cp5.get(Toggle.class,"dataMode").getValue()==1){
    cp5.get(Toggle.class,"dataMode").setColorActive(color(80));
  }else{
    cp5.get(Toggle.class,"dataMode").setColorActive(color(0,116,217));
  }
}


// Événements clavier
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
  
  // Masquer contrôles
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
  println(vitesse);
}

// Toggle du mode data
void dataMode(boolean theFlag) {
  if(theFlag==true) {
    bgMode = bgColor;
    windVitesseMode = vitesse;
    windAmpMode = amplitude;
    dataMode = false;
    // Débloquer contrôles vent + amplirtude + couleur
    cp5.get(Slider.class,"vitesse").unlock();
    cp5.get(Slider.class,"amplitude").unlock();
  }else{
    getDatas();
    bgMode = dataColor;
    windVitesseMode = dataVent;
    windAmpMode = dataVent;
    dataMode = true;
    // Bloquer contrôles vent + amplirtude + couleur
    cp5.get(Slider.class,"vitesse").lock();
    cp5.get(Slider.class,"amplitude").lock();
  }
}

// Bouton ok pour valider la ville
void Ok() {
  ville = cp5.get(Textfield.class,"ville").getText();
  getDatas();
  bgMode = dataColor;
  windVitesseMode = dataVent;
  windAmpMode = dataVent;
}

//mouseWheel
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  tz -= e;
  println(e);
}