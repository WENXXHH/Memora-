/// 用户对单词掌握程度的反馈类型
/// - known: 用户认识该单词
/// - fuzzy: 用户对单词记忆模糊
/// - unknown: 用户不认识该单词
enum FeedbackType { known, fuzzy, unknown }

/// 学习模式
/// - newWord: 学习新词（每次20个单词）
/// - review: 复习已学单词（每次10个单词）
enum LearningMode { newWord, review }
