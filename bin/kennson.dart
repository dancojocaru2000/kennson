import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:json_path/json_path.dart';
import 'package:rfc_6901/rfc_6901.dart';

import 'ppjson.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('file', abbr: 'f', help: 'Read JSON from file instead of stdin', valueHelp: 'filename')
    ..addOption('input', help: 'Read JSON as parameter instead of stdin', valueHelp: 'json input')
    ..addOption('jsonpath', aliases: ['path'], help: 'Display only the matches of the JSON document', valueHelp: 'JSONPath query')
    ..addOption('jsonpointer', aliases: ['pointer'], abbr: 'p', help: 'Display only the matches of the JSON pointer', valueHelp: 'JSON Pointer')
    ..addOption('indent', abbr: 'i', help: 'Set space indentation level (prefix with t for tab indentation)', defaultsTo: '2')
    ..addOption('max-depth', abbr: 'd', help: 'Specify maximum nesting before stopping printing');
    // ..addFlag('force-color', help: "Output using colors even when the environment doesn't allow them", hide: true);
  final ArgResults parsedArgs;
  try {
    parsedArgs = parser.parse(arguments);
  }
  on ArgParserException catch(e) {
    print(e.message);
    print('');
    print(parser.usage);
    exit(1);
  }

  // Get indent
  final indentArg = parsedArgs['indent'] as String;
  final indent = indentArg[0] == 't' ? '\t' * int.parse(indentArg.substring(1)) : ' ' * int.parse(indentArg);

  // Get max depth
  final maxDepthArg = parsedArgs['max-depth'] as String?;
  final maxDepth = int.tryParse(maxDepthArg ?? '');

  // Get JSONPath
  final jsonPath = parsedArgs['jsonpath'] as String?;

  // Get JSON Pointer
  final jsonPointer = parsedArgs['jsonpointer'] as String?;

  // Read
  String jsonInput;
  if (parsedArgs['file'] != null) {
    jsonInput = File(parsedArgs['file']).readAsStringSync();
  }
  else if (parsedArgs['input'] != null) {
    jsonInput = parsedArgs['input'];
  }
  else {
    jsonInput = '';
    while (true) {
      final line = stdin.readLineSync(retainNewlines: true);
      if (line != null) {
        jsonInput += line;
      }
      else {
        break;
      }
    }
  }

  // Parse
  final decodedData;
  try {
    decodedData = jsonDecode(jsonInput);
  }
  catch(_) {
    stderr.writeln('Unable to parse JSON input.');
    exit(1);
  }
  final List<dynamic> data;
  try {
    data = jsonPath != null ? followJsonPath(decodedData, jsonPath) : jsonPointer != null ? followJsonPointer(decodedData, jsonPointer) : [decodedData];
  }
  catch (e) {
    stderr.writeln('JSONPath Error: $e');
    exit(1);
  } 

  // Print
  if (data.isEmpty) {
    stderr.writeln('No match');
  }
  else if (data.length == 1) {
    stdout.write(prettyPrintJson(data[0], indent, maxDepth));
  }
  else {
    for (final match in data) {
      print(prettyPrintJson(match, indent, maxDepth));
    }
  }
}

List<dynamic> followJsonPath(dynamic object, String jsonPath) {
  final path = JsonPath(jsonPath);
  return path.read(object).map((e) => e.value).toList(growable: false);
}

List<dynamic> followJsonPointer(dynamic object, String jsonPointer) {
  final pointer = JsonPointer(jsonPointer);
  return [pointer.read(object)];
}
