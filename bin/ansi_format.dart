const String ESC = '\x1b';
const String CSI = '$ESC[';

class TextFormat {
  final List<TextFormat> children;

  const TextFormat({required this.children});

  @override
  String toString() {
    return children.join('');
  }
}

class ANSIColorText extends TextFormat {
  final ANSIColor? foreground;
  final ANSIColor? background;

  ANSIColorText({this.foreground, this.background, required List<TextFormat> children}) : super(children: children);

  @override
  String toString() {
    var result = '';
    for (final child in children) {
      result += foreground?.enabler ?? '';
      result += background?.backgroundEnabler ?? '';
      result += child.toString();
    }
    result += foreground?.disabler ?? '';
    result += background?.backgroundDisabler ?? '';
    return result;
  }
}

class ANSIFormat extends TextFormat {
  final bool? bold;
  final bool? italic;
  final bool? underline;
  final bool? reverseColor;

  ANSIFormat({this.bold, this.italic, this.underline, this.reverseColor, required List<TextFormat> children}) : super(children: children);

  @override
  String toString() {
    var result = '';
    for (final child in children) {
      if (bold != null) {
        result += bold! ? ANSIBold().enabler : ANSIBold().disabler;
      }
      if (italic != null) {
        result += italic! ? ANSIItalic().enabler : ANSIItalic().disabler;
      }
      if (underline != null) {
        result += underline! ? ANSIUnderline().enabler : ANSIUnderline().disabler;
      }
      if (reverseColor != null) {
        result += reverseColor! ? ANSIReverseVideo().enabler : ANSIReverseVideo().disabler;
      }
      result += child.toString();
    }
    if (bold != null) {
      result += bold! ? ANSIBold().disabler : ANSIBold().enabler;
    }
    if (italic != null) {
      result += italic! ? ANSIItalic().disabler : ANSIItalic().enabler;
    }
    if (underline != null) {
      result += underline! ? ANSIUnderline().disabler : ANSIUnderline().enabler;
    }
    if (reverseColor != null) {
      result += reverseColor! ? ANSIReverseVideo().disabler : ANSIReverseVideo().enabler;
    }
    return result;
  }
}

class Text extends TextFormat {
  final String value;
  const Text(this.value) : super(children: const []);
  @override
  String toString() {
    return value;
  }
}

class ANSIEscape {
  final String enabler;
  final String disabler;

  const ANSIEscape({required this.enabler, required this.disabler});
}

class ANSIBold extends ANSIEscape {
  const ANSIBold() : super(enabler: '${CSI}1m', disabler: '${CSI}22m');
}

class ANSIItalic extends ANSIEscape {
  const ANSIItalic() : super(enabler: '${CSI}3m', disabler: '${CSI}23m');
}

class ANSIUnderline extends ANSIEscape {
  const ANSIUnderline() : super(enabler: '${CSI}4m', disabler: '${CSI}24m');
}

class ANSIReverseVideo extends ANSIEscape {
  const ANSIReverseVideo() : super(enabler: '${CSI}7m', disabler: '${CSI}27m');
}

class ANSIColor extends ANSIEscape {
  const ANSIColor.index(int index, [bool bright = false]) : super(enabler: '$CSI${bright ? 9 : 3}${index}m', disabler: '${CSI}39m');
  const ANSIColor.value(String value) : super(enabler: '$CSI${value}m', disabler: '${CSI}39m');
  String get backgroundEnabler {
    final noCSI = enabler.substring(CSI.length);
    final nom = noCSI.substring(0, noCSI.length - 1);
    final number = int.parse(nom);
    return '$CSI${number + 10}m';
  }
  final String backgroundDisabler = '${CSI}49m';
}

class ANSIColors {
  static const ANSIColor black = ANSIColor.index(0); 
  static const ANSIColor red = ANSIColor.index(1);
  static const ANSIColor green = ANSIColor.index(2);
  static const ANSIColor yellow = ANSIColor.index(3); 
  static const ANSIColor blue = ANSIColor.index(4);
  static const ANSIColor magenta = ANSIColor.index(5); 
  static const ANSIColor cyan = ANSIColor.index(6);
  static const ANSIColor white = ANSIColor.index(7);
  static const ANSIColor brightBlack = ANSIColor.index(0, true); 
  static const ANSIColor brightRed = ANSIColor.index(1, true);
  static const ANSIColor brightGreen = ANSIColor.index(2, true);
  static const ANSIColor brightYellow = ANSIColor.index(3, true); 
  static const ANSIColor brightBlue = ANSIColor.index(4, true);
  static const ANSIColor brightMagenta = ANSIColor.index(5, true); 
  static const ANSIColor brightCyan = ANSIColor.index(6, true);
  static const ANSIColor brightWhite = ANSIColor.index(7, true);
}
