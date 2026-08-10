import 'chess_piece.dart';

class ChessMove {
  final BoardSquare from;
  final BoardSquare to;
  final ChessPiece piece;
  final ChessPiece? capturedPiece;
  final PieceType? promotionType;
  final bool isCastling;
  final bool isEnPassant;
  final bool isCheck;
  final bool isCheckmate;
  final String sanNotation;

  const ChessMove({
    required this.from,
    required this.to,
    required this.piece,
    this.capturedPiece,
    this.promotionType,
    this.isCastling = false,
    this.isEnPassant = false,
    this.isCheck = false,
    this.isCheckmate = false,
    this.sanNotation = '',
  });

  bool get isCapture => capturedPiece != null || isEnPassant;

  ChessMove copyWith({
    BoardSquare? from,
    BoardSquare? to,
    ChessPiece? piece,
    ChessPiece? capturedPiece,
    PieceType? promotionType,
    bool? isCastling,
    bool? isEnPassant,
    bool? isCheck,
    bool? isCheckmate,
    String? sanNotation,
  }) {
    return ChessMove(
      from: from ?? this.from,
      to: to ?? this.to,
      piece: piece ?? this.piece,
      capturedPiece: capturedPiece ?? this.capturedPiece,
      promotionType: promotionType ?? this.promotionType,
      isCastling: isCastling ?? this.isCastling,
      isEnPassant: isEnPassant ?? this.isEnPassant,
      isCheck: isCheck ?? this.isCheck,
      isCheckmate: isCheckmate ?? this.isCheckmate,
      sanNotation: sanNotation ?? this.sanNotation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from.notation,
      'to': to.notation,
      'piece': piece.symbol,
      'capturedPiece': capturedPiece?.symbol,
      'promotionType': promotionType?.name,
      'isCastling': isCastling,
      'isEnPassant': isEnPassant,
      'isCheck': isCheck,
      'isCheckmate': isCheckmate,
      'sanNotation': sanNotation,
    };
  }

  factory ChessMove.fromJson(Map<String, dynamic> json) {
    return ChessMove(
      from: BoardSquare.fromNotation(json['from'] as String)!,
      to: BoardSquare.fromNotation(json['to'] as String)!,
      piece: ChessPiece.fromSymbol(json['piece'] as String)!,
      capturedPiece: json['capturedPiece'] != null
          ? ChessPiece.fromSymbol(json['capturedPiece'] as String)
          : null,
      promotionType: json['promotionType'] != null
          ? PieceType.values.firstWhere((e) => e.name == json['promotionType'])
          : null,
      isCastling: json['isCastling'] as bool? ?? false,
      isEnPassant: json['isEnPassant'] as bool? ?? false,
      isCheck: json['isCheck'] as bool? ?? false,
      isCheckmate: json['isCheckmate'] as bool? ?? false,
      sanNotation: json['sanNotation'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChessMove &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          piece == other.piece &&
          promotionType == other.promotionType;

  @override
  int get hashCode =>
      from.hashCode ^ to.hashCode ^ piece.hashCode ^ promotionType.hashCode;

  @override
  String toString() => sanNotation.isNotEmpty ? sanNotation : '${from.notation}-${to.notation}';
}
