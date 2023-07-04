//import libraries
import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import com.hamoid.*;

OpenCV opencv;
Movie video;
VideoExport videoExport;

//video export settings
int vidLength = 30;
int frames = 12;
int delay = 1;
String title = "face_sorter";

//grid settings
int nextX = 0, nextY = 0;

void setup() {
  size(1080, 1920);
  background(0);
  frameRate(frames);

  //initialize video
  ( video = new Movie(this, "crowd.mp4")).loop();
  while (video.height == 0 ) delay(2);

  //initialize openCV face detection
  opencv = new OpenCV(this, 1080, 960);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  //initialize video export
  videoExport = new VideoExport(this, title + ".mp4");
  videoExport.setFrameRate(frames);
  videoExport.startMovie();
  videoExport.setQuality(100, 0);
}

//video playback settings
void movieEvent(Movie video) {
  video.read();
  video.speed(0.4);
}

void draw() {

  //grid settings
  int numCells = 50;
  float gridCellSize = (float)width / numCells;
  int gridOffsetY = video.height;

  //display video
  opencv.loadImage(video);
  image(video, 0, 0 );
  filter(GRAY);

  //red rectangles
  noFill();
  stroke(255, 0, 0);
  strokeWeight(2);
  Rectangle[] faces = opencv.detect();

  //detect faces & copy them in the grid
  for (int i = 0; i < faces.length; i++) {
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);

    int sx = faces[i].x;
    int sy = faces[i].y;
    int sw = faces[i].width;
    int sh = faces[i].height;
    int dx = (int)(nextX * gridCellSize);
    int dy = (int)(nextY * gridCellSize) + gridOffsetY;
    int dw = (int)gridCellSize;
    int dh = (int)gridCellSize;

    copy(sx, sy, sw, sh, dx, dy, dw, dh);

    //paste one by one / jump to the next row once a row has completed
    nextX++;
    if (nextX >= numCells) {
      nextX = 0;
      nextY++;
      if (nextY >= numCells) {
        exit();
      }
    }
  }

  //start exporting every frame after a delay (first frame is usually white)
  if (frameCount > delay) {
    videoExport.saveFrame();
  }
}
