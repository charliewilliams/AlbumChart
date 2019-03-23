
class Note {

  Note(Integer num) {

    pitchClass = num % 12;
    pitch = num - 21; // this is different from other uses of this code
                      // subtracting 21 means 0 is the bottom note of the piano
  }

  int pitchClass; // 0-11
  int pitch;
}
