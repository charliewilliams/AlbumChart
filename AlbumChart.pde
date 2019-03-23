
/*
01 The Sea Was Never Blue",
 02 Astronomia",
 03 Map and Territory",
 04 Eldridge",
 05 How to Actually Change Your Mind",
 06 Sailing the Farm",
 07 Hide and Seek",
 08 At the Violet Hour",
 09 Light from Other Days",
 10 The River's Tent is Broken",
 */

import processing.pdf.*;

final int trackCount = 10;
int[] trackLengthsSecs = {496, 231, 403, 427, 128, 387, 268, 227, 214, 175};
String[] titles = {
  "The Sea Was Never Blue", 
  "Astronomia", 
  "Map and Territory", 
  "Eldridge", 
  "How to Actually Change Your Mind", 
  "Sailing the Farm", 
  "Hide and Seek", 
  "At the Violet Hour", 
  "Light from Other Days", 
  "The River's Tent is Broken", 
};
String[] noteNames = {"C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B"};
String[] keys =  {"D", "Bbm", "Bm/D", "G", "Am", "E", "A", "Bbm", "Dm", "Bb"};
int[] keyClass = { 2, 10, 11, 7, 9, 4, 9, 10, 2, 10 };
int[] roots = {2, 10, 11, 7, 9, 4, 9, 10, 2, 10};
int[] modes = {1, -1, 0, 1, -1, 1, 1, -1, -1, 1}; // -1 minor, 1 major, 0 mixed

ArrayList<Song>songs = new ArrayList<Song>();
PFont font;

boolean drawText = true;
boolean collapsePitchClasses = true;
int albumMax = 1246;

PGraphics pg;
PGraphicsPDF pdf;

void setup() {

  size(1024, 1024);
  pixelDensity(2);
  colorMode(HSB, 360, 100, 100, 100);
  noLoop();

  pg = createGraphics(width, height);
  pdf = (PGraphicsPDF)createGraphics(width * 2, height * 2, PDF, "render-art.pdf");

  //pg.smooth(4);
  //pdf.smooth(4);

  font = createFont("EBGaramond-SemiBold.ttf", 12);

  for (int i = 0; i < trackCount; i++) {
    songs.add(new Song(titles[i], keys[i], roots[i], modes[i], nf(i + 1, 2) + ".json", trackLengthsSecs[i]));
  }
}

void drawTo(PGraphics p) {

  PVector chartOrigin = new PVector(width * 0.2, height * 0.2);
  PVector chart = new PVector(width * 0.6, height * 0.6);

  p.colorMode(HSB, 360, 100, 100, 100);
  p.ellipseMode(CENTER);
  p.rectMode(CORNER);

  p.background(90);

  if (font != null) {
    p.textFont(font);
  }

  p.textSize(32);
  p.textAlign(CENTER);
  p.text("LARKHALL", width / 2, height * 0.1);
  p.textSize(16);
  p.text("THE SEA WAS NEVER BLUE", width / 2, height * 0.12);
  p.textSize(12);
  p.text("50 minutes. 10 tracks. 15,960 notes", width / 2, height * 0.135);

  p.textAlign(RIGHT);
  p.textSize(16);
  p.text("larkhall.org", width * 0.95, height * 0.95);
  p.textSize(12);

  float rowHeight = chart.y / trackCount;
  int cols = collapsePitchClasses ? 12 : 88;
  float colWidth = chart.x / cols;

  p.translate(chartOrigin.x, chartOrigin.y);

  // draw a box around the chart
  p.noFill();
  p.strokeWeight(0.5);
  p.stroke(200);
  p.rect(0, 0, chart.x, chart.y);

  // draw labels
  if (collapsePitchClasses) {
    p.fill(255);
    p.textAlign(CENTER);
    for (int col = 0; col < cols; col++) {
      String noteName = noteNames[col % 12];
      p.text(noteName, col * colWidth + colWidth / 2, -rowHeight / 8);
    }

    p.text("Count", 13 * colWidth, -rowHeight / 8);
    p.text("Notes", 14 * colWidth, -rowHeight / 8);
    p.text("Pitches", 15 * colWidth, -rowHeight / 8);
  }

  int noteCount = 0;
  int differentNotesCount = 0;

  int[] albumRawNoteOccurrences = new int[88];
  int albumNotesUsedCount = 0;

  int[] albumPitchClassOccurrences = new int[12];

  int songIndex = 0;

  for (Song s : songs) {

    // track title
    if (drawText) {

      p.fill(255);
      p.textAlign(RIGHT);
      p.text(s.title, -10, rowHeight / 2);
    }

    int[] pitchOccurrences = new int[cols];

    int[] pitchClassOccurrences = new int[12];
    int[] rawNoteOccurrences = new int[88];

    int songNoteCount = 0;
    int songDifferentNotesCount = 0;
    int songDifferentPitchClassesCount = 0;

    // count how many times each note happens in this song
    for (Float startTime : s.timestamps) {

      songNoteCount++;
      noteCount++;

      Note n = s.notes.get(startTime);

      int i = collapsePitchClasses ? n.pitchClass : n.pitch;

      if (pitchOccurrences[i] == 0) {
        differentNotesCount++;
      }
      pitchOccurrences[i] = pitchOccurrences[i] + 1;

      //
      i = n.pitchClass;
      if (pitchClassOccurrences[i] == 0) {
        songDifferentPitchClassesCount++;
      }
      pitchClassOccurrences[i] = pitchClassOccurrences[i] + 1;
      albumPitchClassOccurrences[i] = albumPitchClassOccurrences[i] + 1;

      //
      i = n.pitch;
      if (rawNoteOccurrences[i] == 0) {
        songDifferentNotesCount++;
      }
      rawNoteOccurrences[i] = rawNoteOccurrences[i] + 1;

      if (albumRawNoteOccurrences[i] == 0) {
        albumNotesUsedCount++;
      }
      albumRawNoteOccurrences[i] = albumRawNoteOccurrences[i] + 1;
    }

    p.textAlign(CENTER);
    p.text(songNoteCount, 13 * colWidth, rowHeight / 2);
    p.text(songDifferentNotesCount, 14 * colWidth, rowHeight / 2);
    p.text(songDifferentPitchClassesCount, 15 * colWidth, rowHeight / 2);

    //println(s.title + " " + songNoteCount);
    //println(pitchOccurrences);

    int thisSongMax = 0;
    for (int col = 0; col < cols; col++) {
      int count = pitchOccurrences[col];
      if (count > thisSongMax) thisSongMax = count;
    }

    for (int col = 0; col < cols; col++) {

      int count = pitchOccurrences[col];

      if (count == 0) continue;

      float x = col * colWidth;
      float max = lerp(thisSongMax, albumMax, 0.1);

      // just run around the pitch circle
      //float hue = map(col % 12, 0, 12, 0, 360);

      // try to shift according to tonic
      //int offset = keyClass[songIndex] + 6;
      //float hue = map((col + offset) % 12, 0, 12, 0, 360);

      float hue = map(count, 0, thisSongMax, 360, 1);
      float bri = map(count, 0, max, 0, 100);

      color c = color(hue, 50, bri, 100);
      p.fill(c);
      if (!collapsePitchClasses) {
        p.stroke(c);
      }
      p.rect(x, 0, colWidth, rowHeight);

      if (collapsePitchClasses) {
        p.fill(bri > 50 ? 0 : 255);
        p.textAlign(CENTER);
        p.text(count, x + colWidth / 2, rowHeight / 2);
      }
    }

    p.translate(0, rowHeight);
    songIndex++;
  }

  // Summary row
  p.translate(0, rowHeight / 2);
  p.text("15960", 13 * colWidth, rowHeight / 2);
  p.text(albumNotesUsedCount, 14 * colWidth, rowHeight / 2);
  p.text("12", 15 * colWidth, rowHeight / 2);

  if (collapsePitchClasses) {
    for (int col = 0; col < 12; col++) {

      int count = albumPitchClassOccurrences[col];

      float x = col * colWidth;

      float hue = map(count, 0, albumMax, 360, 1);
      float bri = map(count, 0, albumMax, 0, 50);

      color c = color(hue, 50, bri, 100);
      p.fill(c);
      p.rect(x, 0, colWidth, rowHeight);

      p.fill(bri > 50 ? 0 : 255);
      p.textAlign(CENTER);
      p.text(count, x + colWidth / 2, rowHeight / 2);
    }
  }

  println("---"); 
  println(noteCount);
}

void draw() {

  pg.beginDraw();
  drawTo(pg);
  pg.endDraw();

  image(pg, 0, 0);
  pg.save("render.png");

  pdf.beginDraw();
  drawTo(pdf);
  pdf.dispose();
  pdf.endDraw();
}

String timeFormat(int millis) {

  int totalSecs = millis / 1000;
  int min = totalSecs / 60;
  int sec = totalSecs % 60;

  return nf(min) + ":" + nf(sec, 2);
}
