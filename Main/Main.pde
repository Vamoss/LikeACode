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

void setup(){
  size(1024, 768);
  loadAllLines();
}

void draw(){
  background(255);
  switch(state){
    case DRAWING:
      if(millis()-lastInteraction>autoEnterScreensaver) {
        saveCurrentLine();
        changeState(State.ANIMATING);
      }
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
  println(percent);
  
  int total = 0;
  for(int i=0; i<lines.size(); i++) 
    total+=lines.get(i).size();
  int totalToPrint = int(percent*total);
  int totalPrinted = 0;
      
  for(int i=0; i<lines.size() && totalPrinted<totalToPrint; i++){
   ArrayList<PVector> line = lines.get(i);
   if(line.size()>0){
     prev = line.get(0);
     for(int j=0; j<line.size() && totalPrinted<totalToPrint;j++){
       PVector coord = line.get(j);
       line(prev.x, prev.y, coord.x, coord.y);
       prev = coord;
       totalPrinted++;
     }
   }
  }
}

void drawAnimating(){
  println(currentAllLines);
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
 line.add(new PVector(mouseX, mouseY));
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