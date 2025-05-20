enum ContentCategory {
  accounting,    // 会計一般
  taxation,      // 税務
  financial,     // 財務分析
  legal,         // 法務関連
  general,       // 一般的な質問
  inappropriate, // 不適切なコンテンツ
  unsupported,   // サポート対象外
}

class ContentClassifier {
  // 質問内容のカテゴリを分類
  static ContentCategory classifyContent(String message) {
    // 会計に関する質問かどうか
    if (RegExp(r'会計|簿記|仕訳|勘定科目|財務諸表|貸借対照表|損益計算書', caseSensitive: false).hasMatch(message)) {
      return ContentCategory.accounting;
    }
    
    // 税務に関する質問かどうか
    if (RegExp(r'税金|税務|確定申告|消費税|所得税|法人税|税率|控除|経費|青色申告', caseSensitive: false).hasMatch(message)) {
      return ContentCategory.taxation;
    }
    
    // 財務分析に関する質問かどうか
    if (RegExp(r'財務分析|比率|収益性|安全性|流動性|ROI|ROA|ROE|CF|キャッシュフロー', caseSensitive: false).hasMatch(message)) {
      return ContentCategory.financial;
    }
    
    // 法務関連の質問かどうか
    if (RegExp(r'法律|契約|規制|コンプライアンス|法令', caseSensitive: false).hasMatch(message)) {
      return ContentCategory.legal;
    }
    
    // 不適切なコンテンツかどうか
    if (RegExp(r'脱税|詐欺|違法|闇金|マネーロンダリング', caseSensitive: false).hasMatch(message)) {
      return ContentCategory.inappropriate;
    }
    
    // サポート対象外かどうか
    if (RegExp(r'投資|株価|仮想通貨|ビットコイン|FX|為替', caseSensitive: false).hasMatch(message)) {
      return ContentCategory.unsupported;
    }
    
    // デフォルトは一般的な質問として扱う
    return ContentCategory.general;
  }
  
  // カテゴリごとの補足プロンプトを取得
  static String getSupplementaryPrompt(ContentCategory category) {
    switch (category) {
      case ContentCategory.accounting:
        return '以下の質問は会計に関するものです。日本の会計基準に基づいて正確に回答してください。';
      case ContentCategory.taxation:
        return '以下の質問は税務に関するものです。一般的な税務情報のみを提供し、個別具体的な税務判断は税理士に相談するよう促してください。';
      case ContentCategory.financial:
        return '以下の質問は財務分析に関するものです。財務指標の意味や一般的な解釈を説明してください。';
      case ContentCategory.legal:
        return '以下の質問は法務に関するものです。一般的な情報のみを提供し、具体的な法的アドバイスは弁護士に相談するよう促してください。';
      case ContentCategory.inappropriate:
        return '以下の質問には、不適切または違法な内容が含まれている可能性があります。法令に準拠した情報のみを提供し、違法行為を促す内容は含めないでください。';
      case ContentCategory.unsupported:
        return '以下の質問はアプリのサポート対象外のトピックを含んでいる可能性があります。一般的な情報のみを提供し、投資アドバイスなどは行わないでください。';
      case ContentCategory.general:
      default:
        return '以下の質問に対して、会計や財務の専門家として回答してください。';
    }
  }
}
