import java.io.File;

int autoEnterScreensaver = 5000;
int autoNextScreensaver = 5000;

int currentAllLines = 0;
ArrayList<ArrayList<ArrayList<PVector>>> allLines = new ArrayList<ArrayList<ArrayList<PVector>>>();
ArrayList<ArrayList<PVector>> currentLines = new ArrayList<ArrayList<PVector>>();

int lastInteraction = 0;

enum State {DRAWING,ANIMATING};
State state = State.DRAWING;

int animatingStart = 0;

PVector topLeft = new PVector();
PVector topRight = new PVector();
PVector bottomLeft = new PVector();
PVector bottomRight = new PVector();

void setup(){
  size(1024, 768);
  loadAllLines();
}

void draw(){
  background(0);
  switch(state){
    case DRAWING:
      if(millis()-lastInteraction>autoEnterScreensaver) {
        saveCurrentLine();
        changeState(State.ANIMATING);
      }
      fill(255);
      noStroke();
      arc(30, 30, 30, 30, 0, TWO_PI*(1-(float)(millis()-lastInteraction)/(float)autoEnterScreensaver), PIE);
      drawLines(currentLines, 1);
      break;
    case ANIMATING:
      drawAnimating();
      break;
  }
}

void changeState(State s){
  state = s;
}

void drawLines(ArrayList<ArrayList<PVector>> lines, float percent){
  PVector prev = new PVector();
  
  int total = 0;
  for(int i=0; i<lines.size(); i++) 
    total+=lines.get(i).size();
  int totalToPrint = int(percent*total);
  int totalPrinted = 0;
      
  for(int i=0; i<lines.size() && totalPrinted<totalToPrint; i++){
   ArrayList<PVector> line = lines.get(i);
   if(line.size()>0){
     prev = line.get(0);
     topLeft.x = prev.x;
     topLeft.y = prev.y;
     topRight.x = prev.x;
     topRight.y = prev.y;
     for(int j=1; j<line.size() && totalPrinted<totalToPrint;j++){
       PVector coord = line.get(j);
       drawLine(prev, coord);
       prev = coord;
       totalPrinted++;
     }
   }
  }
}

void drawLine(PVector prev, PVector coord){
  float angle = PI/4;//atan2(coord.x-prev.x, coord.y-prev.y)+PI/2;//we sum PI/2 to add 90o degrees and rotate properly
  float velocity = dist(coord.x, coord.y, prev.x, prev.y);
  float x = cos(angle);
  float y = sin(angle);
  float size = lerp(20, 2, max(0, min(1, velocity/100)));
  bottomLeft.x = topRight.x;
  bottomLeft.y = topRight.y;
  bottomRight.x = topLeft.x;
  bottomRight.y = topLeft.y;
  topLeft.x = coord.x-size*x;
  topLeft.y = coord.y-size*y;
  topRight.x = coord.x+size*x;
  topRight.y = coord.y+size*y;
  
  stroke(255);
  fill(255);
  strokeWeight(1);
  beginShape();
  vertex(topLeft.x, topLeft.y);
  vertex(topRight.x, topRight.y);
  vertex(bottomLeft.x, bottomLeft.y);
  vertex(bottomRight.x, bottomRight.y);
  endShape(CLOSE);
  
  stroke(255);
  strokeWeight(3);
  noFill();
  line(prev.x, prev.y, coord.x, coord.y);
}

void drawAnimating(){
  if(allLines.size()>0){
    drawLines(allLines.get(currentAllLines), parseFloat(millis()-animatingStart)/parseFloat(autoNextScreensaver/2));
  }
  if(millis()-animatingStart>autoNextScreensaver){
    animatingStart = millis();
    currentAllLines++;
    if(currentAllLines>=allLines.size())
      currentAllLines = 0;
  }
}

void mousePressed(){
  lastInteraction = millis();
 currentLines.add(new ArrayList<PVector>());
 changeState(State.DRAWING);
}

void mouseDragged(){
 lastInteraction = millis();
 ArrayList<PVector> line = currentLines.get(currentLines.size()-1);
 if(line.size()>0){
   PVector prev = line.get(line.size()-1);
   if(dist(mouseX, mouseY, prev.x, prev.y)>2){
     line.add(new PVector(mouseX, mouseY));
   }
 }else{
   line.add(new PVector(mouseX, mouseY));
 }
}

void mouseReleased(){
  lastInteraction = millis();
  if(currentLines.get(currentLines.size()-1).size()<1){
    currentLines.remove(currentLines.size()-1);
    println("line null, removed");
  }
}

void saveCurrentLine(){
  //String data = ""; 
  String[] data = new String[0];
  for(int i=0; i<currentLines.size(); i++){
   ArrayList<PVector> line = currentLines.get(i);
   String lineData = "";
   for(int j=0; j<line.size();j++){
     PVector coord = line.get(j);
     if(lineData!="") lineData+=",";
     lineData += coord.x + ":" + coord.y;
   }
   if(lineData!="")
     data = append(data, lineData);
  }
  if(data.length>0)
    saveStrings("data/lines/draw"+millis()+".txt", data);
  
  allLines.add(currentLines);
  
  //reset
  currentLines = new ArrayList<ArrayList<PVector>>();
}

void loadAllLines(){
  File dir = new File(dataPath("lines"));
  File [] files = dir.listFiles();
  for (int i = 0; i < files.length; i++)   
  {
    String path = files[i].getAbsolutePath();
    if(path.toLowerCase().endsWith(".txt"))
    {
      //println(path.toLowerCase(), i);
      String[] allLinesData = loadStrings(path);
      ArrayList<ArrayList<PVector>> lines = new ArrayList<ArrayList<PVector>>();
      for (int j = 0 ; j < allLinesData.length; j++) {
        String[] linesData = split(allLinesData[j], ',');
        ArrayList<PVector> line = new ArrayList<PVector>();
        for(int k=0; k<linesData.length;k++){
          String[] coordData = split(linesData[k], ':');
          PVector coord = new PVector(int(coordData[0]), int(coordData[1]));
          line.add(coord);
        }
        lines.add(line);
      }
      allLines.add(lines);
    }
  }
}