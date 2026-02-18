class NoteConverter {
  static const A4 = 440.0;

  static const notes = [
    "C","C#","D","D#","E","F",
    "F#","G","G#","A","A#","B"
  ];

  static Map<String, dynamic> fromFrequency(double freq) {
    double midi = 69 + 12 * log(freq / A4) / ln2;

    int nearestMidi = midi.round();

    double nearestFreq =
        A4 * pow(2, (nearestMidi - 69) / 12);

    double cents =
        1200 * log(freq / nearestFreq) / ln2;

    return {
      "note": notes[nearestMidi % 12],
      "octave": (nearestMidi ~/ 12) - 1,
      "cents": cents,
    };
  }
}
