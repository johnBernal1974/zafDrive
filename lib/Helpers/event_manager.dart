
import 'package:event_bus/event_bus.dart';

class EventManager {
  static final EventBus _eventBus = EventBus();

  static void sendEvent(dynamic event) {
    _eventBus.fire(event);
  }

  static void listenEvent(void Function(dynamic event) onData) {
    _eventBus.on().listen(onData);
  }
}