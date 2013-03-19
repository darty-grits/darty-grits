part of grits_shared;

class GameTimer {
  int target = 0;
  int base = 0;
  int last = 0;
  GlobalTimer timer;

  GameTimer(GlobalTimer this.timer, [seconds = 0]) {
    base = timer.time;
    last = timer.time;
    target = seconds;
  }

  set([seconds = 0]) {
    target = seconds;
    base = timer.time;
  }

  reset() {
    base = timer.time;
  }

  tick() {
    var delta = timer.time - last;
    last = timer.time;
    return delta;
  }

  delta() {
    return timer.time - base - target;
  }
}

class GlobalTimer {
  int _last = 0;
  int time;
  int timeScale = 1;
  double maxStep = 0.05;

  GlobalTimer() {
    time = new DateTime.now().millisecondsSinceEpoch;
  }

  step() {
    var current = new DateTime.now().millisecondsSinceEpoch;
    var delta = (current - _last) / 1000;
    time += Math.min(delta, maxStep) * timeScale;
    _last = current;
  }
}
