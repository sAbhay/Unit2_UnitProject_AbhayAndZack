import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.dynamics.*;

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Box2DProcessing box2d;

ArrayList<Sand> sand = new ArrayList<Sand>();
Boundary[] boundary = new Boundary[4];

int h, s, b;

Kinect kinect;
KinectTracker tracker;

boolean settings = false;

boolean kinectControl = false;

int numberOfButtons = 14;
Button[] buttons = new Button[numberOfButtons];

ArrayList<Platform> p = new ArrayList<Platform>();

int mode = 0;
String[] modes = {"Sand", "Horizontal Platform", "Vertical Platform"};

int verticalGravity = -10;
int horizontalGravity = 0;

void setup()
{
  noStroke();
  fullScreen(P3D);

  kinect = new Kinect(this);
  tracker = new KinectTracker();

  colorMode(HSB, 255, 255, 255);

  rectMode(CENTER);
  textAlign(CENTER);

  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(horizontalGravity, verticalGravity);
  box2d.setContinuousPhysics(true);

  boundary[0] = new Boundary(-2, height/2, 2, height, color(255));
  boundary[1] = new Boundary(width/2, height - 1, width, 2, color(255));
  boundary[2] = new Boundary(width - 1, height/2, 2, height, color(255));
  boundary[3] = new Boundary(width/2, 1, width, 2, color(255));

  minim = new Minim(this);
  music = minim.getLineOut();
  recorder = minim.createRecorder(music, "Sweet Tunez.wav");
  time = millis();

  buttons[0] = new Button(width/2 - 50, height/2 + 100, 20, 15, "-", "Octave", -1);
  buttons[1] = new Button(width/2 + 50, height/2 + 100, 20, 15, "+", "Octave", 1);
  buttons[2] = new Button(2*width/3 - 50, 2*height/3 + 20, 20, 15, "-", "NextScale", -1);
  buttons[3] = new Button(2*width/3 + 50, 2*height/3 + 20, 20, 15, "+", "NextScale", 1);
  buttons[4] = new Button(width/3 + 50, 2*height/3 + 20, 20, 15, "Save", "Save", 1);
  buttons[5] = new Button(width/4 - 50, height/4, 20, 15, "-", "Mode", -1);
  buttons[6] = new Button(width/4 + 50, height/4, 20, 15, "+", "Mode", 1);
  buttons[7] = new Button(width/5 - 50, 5*height/6 + 50, 20, 15, "-", "horizontalGravity", -1);
  buttons[8] = new Button(width/5 + 50, 5*height/6 + 50, 20, 15, "+", "horizontalGravity", 1);
  buttons[9] = new Button(width/5 - 50, 5*height/6 + 100, 20, 15, "-", "verticalGravity", -1);
  buttons[10] = new Button(width/5 + 50, 5*height/6 + 100, 20, 15, "+", "verticalGravity", 1);
  buttons[numberOfButtons-3] = new Button(width/3, height/3, 20, 15, "Recorder", "Record", 1);
  buttons[numberOfButtons-2] = new Button(width/2 + 100, height/2 - 100, 20, 15, "Chords", "Chords", 1);
  buttons[numberOfButtons-1] = new Button(width/2 - 100, height/2 - 100, 20, 15, "Kinect Control", "KinectControl", 1);
}

void draw()
{
  if (selectedOctave < 1) selectedOctave = 1;
  if (selectedOctave > octave.length - 2) selectedOctave = octave.length - 2;

  if (nextScale < 0) nextScale = 24;
  if (nextScale > 24) nextScale = 0;

  if (mode < 0) mode = 0;
  if (mode > modes.length - 1) mode = modes.length - 1;

  if (time < millis())
  {
    GenerateMusic(60);
    time += 10000;

    h = (int) random(255);
    s = 255;
    b = 255;
  }

  background(255);

  if (!settings)
  {
    box2d.step();

    for (int i = 0; i < boundary.length; i++)
    {
      boundary[i].display();
    }

    if (kinectControl)
    {
      tracker.track();
      tracker.display();

      PVector v1 = tracker.getPos();
      PVector v2 = tracker.getLerpedPos();
      fill(0, 128, 255);
      ellipse(v1.x, v1.y, 5, 5);

      fill(128, 255, 0);
      ellipse(v2.x, v2.y, 5, 5);

      sand.add(new Sand(v1.x, v1.y, 10, 10, color(h, s, b)));
    } else
    {
      if (mode == 0)
      {
        sand.add(new Sand(mouseX, mouseY, 10, 10, color(h, s, b)));
      }
    }
  }


  for (int i = 0; i < sand.size(); i++)
  {
    sand.get(i).display();
  }

  for (int i = 0; i < p.size(); i++)
  {
    p.get(i).display();
  }

  if (settings)
  {
    settingsMenu();
  }
}

void mousePressed()
{
  if (settings)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      buttons[i].change();
    }
  }

  if (!settings)
  {
    if (mode == 0 && mouseButton == RIGHT)
    {
      int alignment = (int) random(2);

      if (alignment == 0)
      {
        p.add(new Platform(mouseX, mouseY, (int) random(50, 75), 10, color(random(0, 128))));
      } else if (alignment == 1)
      {
        p.add(new Platform(mouseX, mouseY, 10, (int) random(50, 75), color(random(0, 128))));
      }
    }

    if (mode == 1)
    {
      p.add(new Platform(mouseX, mouseY, (int) random(50, 75), 10, color(random(0, 128))));
    }

    if (mode == 2)
    {
      p.add(new Platform(mouseX, mouseY, 10, (int) random(50, 75), color(random(0, 128))));
    }
  }
}

void keyPressed()
{
  if (key == BACKSPACE)
  {
    for (Sand s : sand)
    {
      s.killBody();
    }

    for (Platform platform : p)
    {
      platform.killBody();
    }

    sand.clear();
    p.clear();
  }

  if (key == ESC)
  {
    key = 0;

    if (settings)
    {
      settings = false;
    } else if (!settings)
    {
      settings = true;
    }
  }
}

void settingsMenu()
{
  fill(255);
  rect(width/2, height/2, width, height);

  fill(0);
  text("Now Playing From: " + scaleName[scale], width/2, height/2);

  text("Octave: " + selectedOctave, width/2, height/2 + 100);

  for (int i = 0; i < buttons.length-2; i++)
  {
    buttons[i].display(true);
  }

  buttons[numberOfButtons-3].display(recorder.isRecording());
  buttons[numberOfButtons-2].display(chords);
  buttons[numberOfButtons-1].display(kinectControl);

  if (nextScale != 0)
  {
    fill(0);
    text("Playing Next: " + scaleName[nextScale], 2*width/3, 2*height/3);
  } else {
    fill(0);
    text("Playing Next: Random", 2*width/3, 2*height/3);
  }

  fill(0);
  text("Mode: " + modes[mode], width/4, height/4 - 10);
  
  text("Gravity = (" + horizontalGravity + "," + verticalGravity + ")", width/5, 5*height/6);
  text("Horizontal", width/5, 5*height/6 + 60);
  text("Vertical", width/5, 5*height/6 + 110);
}