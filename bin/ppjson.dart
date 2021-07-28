import 'ansi_format.dart';

String prettyPrintJson(dynamic object, String indent, [int? maxDepth]) {
  var result = '';
  final stack = <_PrettyPrintStackObject>[];
  stack.add(_PrettyPrintStackObject(object, 0));
  while (stack.isNotEmpty) {
    final elem = stack.removeLast();
    final obj = elem.object is _PrettyPrintTrailingComma ? elem.object.object : elem.object;
    final trailingComma = elem.object is _PrettyPrintTrailingComma;
    var suppressTrailingComma = false;

    result += indent * elem.level;
    String formatObject(dynamic obj) {
      if (obj is Map) {
        String startStr;
        if (obj.isEmpty) {
          startStr = '{}';
        }
        else if (elem.level == maxDepth) {
          startStr = '{...}';
        }
        else {
          startStr = '{';
          suppressTrailingComma = true;
        }
        final thisResult = ANSIColorText(
          foreground: ANSIColors.blue,
          children: [Text(startStr),],
        ).toString();
        if (elem.level != maxDepth && obj.isNotEmpty) {
          stack.add(_PrettyPrintStackObject(trailingComma ? _PrettyPrintTrailingComma(_PrettyPrintMapEnd()) : _PrettyPrintMapEnd(), elem.level));
          final entries = obj.entries;
          stack.add(_PrettyPrintStackObject(entries.last, elem.level + 1));
          stack.addAll(entries.toList(growable: false).reversed.skip(1).map((e) => _PrettyPrintStackObject(_PrettyPrintTrailingComma(e), elem.level + 1)));
        }
        return thisResult;
      }
      else if (obj is List) {
        String startStr;
        if (obj.isEmpty) {
          startStr = '[]';
        }
        else if (elem.level == maxDepth) {
          startStr = '[...]';
        }
        else {
          startStr = '[';
          suppressTrailingComma = true;
        }
        final thisResult = ANSIColorText(
          foreground: ANSIColors.cyan,
          children: [Text(startStr),],
        ).toString();
        if (elem.level != maxDepth && obj.isNotEmpty) {
          stack.add(_PrettyPrintStackObject(trailingComma ? _PrettyPrintTrailingComma(_PrettyPrintArrayEnd()) : _PrettyPrintArrayEnd(), elem.level));
          stack.add(_PrettyPrintStackObject(obj.last, elem.level + 1));
          stack.addAll(obj.reversed.skip(1).map((o) => _PrettyPrintStackObject(_PrettyPrintTrailingComma(o), elem.level + 1)));
        }
        return thisResult;
      }
      else if (obj is MapEntry) {
        return TextFormat(
          children: [
            ANSIColorText(
              foreground: ANSIColors.brightYellow,
              children: [Text('"${obj.key}"'),]
            ),
            Text(': '),
            Text(formatObject(obj.value)),
          ],
        ).toString();
      }
      else if (obj is String) {
        return ANSIColorText(
          foreground: ANSIColors.magenta,
          children: [Text('"$obj"'),],
        ).toString();
      }
      else if (obj is double || obj is int) {
        return ANSIColorText(
          foreground: ANSIColors.brightCyan,
          children: [Text(obj.toString()),],
        ).toString();
      }
      else if (obj == true) {
        return ANSIFormat(
          underline: true,
          children: [
            ANSIColorText(
              foreground: ANSIColors.green,
              children: [Text(obj.toString()),],
            ),
          ],
        ).toString();
      }
      else if (obj == false) {
        return ANSIFormat(
          underline: true,
          children: [
            ANSIColorText(
              foreground: ANSIColors.red,
              children: [Text(obj.toString()),],
            ),
          ],
        ).toString();
      }
      else if (obj == null) {
        return ANSIFormat(
          underline: true,
          children: [
            ANSIColorText(
              foreground: ANSIColors.brightBlue,
              children: [Text('null'),],
            ),
          ],
        ).toString();
      }
      else if (obj is _PrettyPrintMapEnd) {
        return ANSIColorText(
          foreground: ANSIColors.blue,
          children: [Text('}'),],
        ).toString();
      }
      else if (obj is _PrettyPrintArrayEnd) {
        return ANSIColorText(
          foreground: ANSIColors.cyan,
          children: [Text(']'),],
        ).toString();
      }
      else {
        throw Exception('Unexpected object of unknown type: $obj ${obj.runtimeType}');
      }
    }
    result += formatObject(obj);

    if (trailingComma && !suppressTrailingComma) {
      result += ',';
    }

    result += '\n';
  }
  return result;
}

class _PrettyPrintStackObject {
  final dynamic object;
  final int level;
  _PrettyPrintStackObject(this.object, this.level);
}

class _PrettyPrintTrailingComma {
  final dynamic object;
  _PrettyPrintTrailingComma(this.object);
}

class _PrettyPrintMapEnd {}
class _PrettyPrintArrayEnd {}
