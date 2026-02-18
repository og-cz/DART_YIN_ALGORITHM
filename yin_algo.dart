import 'dart:math';

class YinPitchDetector {
  final int sampleRate;
  final int bufferSize;
  final double threshold;

  late List<double> yinBuffer;

  YinPitchDetector(
    this.sampleRate,
    this.bufferSize, {
    this.threshold = 0.15,
  }) {
    yinBuffer = List.filled(bufferSize ~/ 2, 0);
  }

  double getPitch(List<double> buffer) {
    int tauEstimate = _absoluteThreshold(buffer);

    if (tauEstimate != -1) {
      double betterTau = _parabolicInterpolation(tauEstimate);
      return sampleRate / betterTau;
    }

    return -1;
  }

  void _difference(List<double> buffer) {
    int half = bufferSize ~/ 2;

    for (int tau = 0; tau < half; tau++) {
      yinBuffer[tau] = 0;

      for (int i = 0; i < half; i++) {
        double delta = buffer[i] - buffer[i + tau];
        yinBuffer[tau] += delta * delta;
      }
    }
  }

  void _cumulativeMeanNormalizedDifference() {
    int half = bufferSize ~/ 2;
    yinBuffer[0] = 1;

    double runningSum = 0;

    for (int tau = 1; tau < half; tau++) {
      runningSum += yinBuffer[tau];
      yinBuffer[tau] *= tau / runningSum;
    }
  }

  int _absoluteThreshold(List<double> buffer) {
    _difference(buffer);
    _cumulativeMeanNormalizedDifference();

    int half = bufferSize ~/ 2;

    for (int tau = 2; tau < half; tau++) {
      if (yinBuffer[tau] < threshold) {
        while (tau + 1 < half &&
            yinBuffer[tau + 1] < yinBuffer[tau]) {
          tau++;
        }
        return tau;
      }
    }

    return -1;
  }

  double _parabolicInterpolation(int tauEstimate) {
    int x0 = tauEstimate < 1 ? tauEstimate : tauEstimate - 1;
    int x2 = tauEstimate + 1 < yinBuffer.length
        ? tauEstimate + 1
        : tauEstimate;

    if (x0 == tauEstimate || x2 == tauEstimate) {
      return tauEstimate.toDouble();
    }

    double s0 = yinBuffer[x0];
    double s1 = yinBuffer[tauEstimate];
    double s2 = yinBuffer[x2];

    return tauEstimate +
        (s2 - s0) / (2 * (2 * s1 - s2 - s0));
  }
}
