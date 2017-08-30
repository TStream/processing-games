//Global Variables
circle c = new circle();
line[] lines = new line[3];
boolean end=false;
boolean intro=true;
int score=0;

//the Setup Function
void setup(){
  size(500,800);
  for(int i = 0;i<3;i++){
    lines[i]=new line(i);
  }
}


void draw(){
  background(0);
  if(end){
    c.move();
  }
  c.drawCircle();
  if(end){
    c.down();
  }
  c.checkForCollision();
  for(int i = 0;i<3;i++){
    lines[i].drawLine();
    lines[i].checkPosition();
  }
  fill(0);
  stroke(255);
  textSize(32);
  if(end){
    rect(20,20,100,50);
    fill(255);
    text(score,30,58);
  }else{
    rect(150,100,200,50);
    rect(150,200,200,50);
    if(!intro) rect(110,300,300,50);
    fill(255);
    if(intro){
      text("Flappy Code",155,140);
      text("Click to Play",155,240);
    }else{
      text("game over",170,140);
      text("score",180,240);
      text(score,280,240);
      text("Click to Play Again",115,340);
    }
  }
}

//the bird that the player will be controling
class circle{
  float xPos,yPos,ySpeed;
  circle(){
    xPos = 250;
    yPos = 400;
  }
  void drawCircle(){
    stroke(255);
    noFill();
    strokeWeight(2);
    ellipse(xPos,yPos,20,20);
  }
  void up(){
    ySpeed=-10; 
  }
  void down(){
    ySpeed+=0.4; 
  }
  void move(){
    yPos+=ySpeed; 
    for(int i = 0;i<3;i++){
      lines[i].xPos-=3;
    }
  }
  void checkForCollision(){
    if(yPos>800){
      end=false;
    }
    for(int i = 0;i<3;i++){
      if( (xPos<lines[i].xPos+10 && xPos>lines[i].xPos-10) && (yPos<lines[i].opening-100 || yPos>lines[i].opening+100) ){
       end=false; 
      }
    }
  } 
}

//the lines that the player will try to avoid
class line{
  float xPos, opening;
  boolean cashed = false;
  line(int i){
    xPos = 100+(i*200);
    opening = random(600)+100;
  }
  void drawLine(){
    line(xPos,0,xPos,opening-100);  
    line(xPos,opening+100,xPos,800);
  }
  void checkPosition(){
    if(xPos<0){
      xPos+=(200*3);
      opening = random(600)+100;
      cashed=false;
    } 
    if(xPos<250 && cashed==false){
      cashed=true;
      score++; 
    }
  }
}


void reset(){
  end=true;
  score=0;
  c.yPos=400;
  for(int i = 0;i<3;i++){
    lines[i].xPos+=550;
    lines[i].cashed = false;
  }
}

//the mouse pressed event
void mousePressed(){
  c.up();
  intro=false;
  if(end==false){
    reset();
  }
}

//the key pressed event
void keyPressed(){
  c.up(); 
  intro=false;
  if(end==false){
    reset();
  }
}