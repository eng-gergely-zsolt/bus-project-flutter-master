import 'dart:async';

final appBloc = AppPropertiesBloc();

class AppPropertiesBloc{
  StreamController<String> _title = StreamController<String>.broadcast();

  Stream<String> get titleStream => _title.stream;

  updateTitle(){
    _title.sink.add("");
  }

  StreamController<String> _fab = StreamController<String>.broadcast();

  Stream<String> get fabStream => _title.stream;

  updateFab(){
    _title.sink.add("");
  }

  dispose() {
    _title.close();
    _fab.close();
  }
}