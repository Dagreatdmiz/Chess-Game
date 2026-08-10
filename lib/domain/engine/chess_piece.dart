enum PieceType { pawn, knight, bishop, rook, queen, king }

enum PieceColor { white, black }

extension PieceColorExtension on PieceColor {
  PieceColor get opponent => this == PieceColor.white ? PieceColor.black : PieceColor.white;
}

class ChessPiece {
  final PieceType type;
  final PieceColor color;
  final bool hasMoved;

  const ChessPiece({
    required this.type,
    required this.color,
    this.hasMoved = false,
  });

  ChessPiece copyWith({
    PieceType? type,
    PieceColor? color,
    bool? hasMoved,
  }) {
    return ChessPiece(
      type: type ?? this.type,
      color: color ?? this.color,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }

  String get symbol {
    switch (type) {
      case PieceType.pawn:
        return color == PieceColor.white ? 'P' : 'p';
      case PieceType.knight:
        return color == PieceColor.white ? 'N' : 'n';
      case PieceType.bishop:
        return color == PieceColor.white ? 'B' : 'b';
      case PieceType.rook:
        return color == PieceColor.white ? 'R' : 'r';
      case PieceType.queen:
        return color == PieceColor.white ? 'Q' : 'q';
      case PieceType.king:
        return color == PieceColor.white ? 'K' : 'k';
    }
  }

  int get value {
    switch (type) {
      case PieceType.pawn:
        return 1;
      case PieceType.knight:
        return 3;
      case PieceType.bishop:
        return 3;
      case PieceType.rook:
        return 5;
      case PieceType.queen:
        return 9;
      case PieceType.king:
        return 1000;
    }
  }

  static ChessPiece? fromSymbol(String char) {
    if (char.isEmpty) return null;
    final color = char == char.toUpperCase() ? PieceColor.white : PieceColor.black;
    switch (char.toUpperCase()) {
      case 'P':
        return ChessPiece(type: PieceType.pawn, color: color);
      case 'N':
        return ChessPiece(type: PieceType.knight, color: color);
      case 'B':
        return ChessPiece(type: PieceType.bishop, color: color);
      case 'R':
        return ChessPiece(type: PieceType.rook, color: color);
      case 'Q':
        return ChessPiece(type: PieceType.queen, color: color);
      case 'K':
        return ChessPiece(type: PieceType.king, color: color);
      default:
        return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChessPiece &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          color == other.color &&
          hasMoved == other.hasMoved;

  @override
  int get hashCode => type.hashCode ^ color.hashCode ^ hasMoved.hashCode;
}

class BoardSquare {
  final int row; // 0 to 7 (0 is rank 8, 7 is rank 1)
  final int col; // 0 to 7 (0 is file 'a', 7 is file 'h')

  const BoardSquare(this.row, this.col);

  bool get isValid => row >= 0 && row < 8 && col >= 0 && col < 8;

  String get notation {
    final file = String.fromCharCode('a'.codeUnitAt(0) + col);
    final rank = 8 - row;
    return '$file$rank';
  }

  static BoardSquare? fromNotation(String str) {
    if (str.length != 2) return null;
    final col = str.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.tryParse(str[1]);
    if (rank == null || rank < 1 || rank > 8 || col < 0 || col > 7) return null;
    return BoardSquare(8 - rank, col);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardSquare &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => notation;
}
