import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error == null) {
      return '予期しないエラーが発生しました';
    }

    // Firebase
    if (error is FirebaseException) {
      return _getFirebaseErrorMessage(error);
    }

    // Firestor
    if (error is FirebaseException) {
      return _getFirestoreErrorMessage(error);
    }

    // 文字列
    if (error is String) {
      return error;
    }

    // 一般的なExceptionの処理
    final errorString = error.toString().toLowerCase();

    // ネットワーク関連のエラー
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('internet') ||
        errorString.contains('timeout')) {
      return 'インターネットに接続できません。\n接続を確認してもう一度お試しください。';
    }

    // 権限関連
    if (errorString.contains('permission') ||
        errorString.contains('denied') ||
        errorString.contains('unauthorized')) {
      return '操作を実行する権限がありません';
    }

    // データが見つからない
    if (errorString.contains('not found') || errorString.contains('見つかりません')) {
      return 'データが見つかりませんでした';
    }

    // 既に存在する場合
    if (errorString.contains('already exists') ||
        errorString.contains('already')) {
      return 'すでに登録されています';
    }

    // デフォルトメッセージ
    return 'エラーが発生しました。\nしばらくしてからもう一度お試しください。';
  }

  /// Firebaseエラーメッセージを取得
  static String _getFirebaseErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return '操作を実行する権限がありません';
      case 'unavailable':
        return 'サービスに接続できません。\nしばらくしてからもう一度お試しください。';
      case 'network-request-failed':
        return 'ネットワークエラーが発生しました。\nインターネット接続を確認してください。';
      case 'deadline-exceeded':
        return 'リクエストがタイムアウトしました。\nもう一度お試しください。';
      case 'unauthenticated':
        return '認証が必要です。\nアプリを再起動してください。';
      case 'already-exists':
        return 'すでに登録されています';
      case 'not-found':
        return 'データが見つかりませんでした';
      case 'invalid-argument':
        return '入力内容に問題があります';
      case 'resource-exhausted':
        return 'サーバーが混み合っています。\nしばらくしてからお試しください。';
      case 'failed-precondition':
        return '操作を実行するための条件が満たされていません';
      case 'aborted':
        return '操作が中断されました';
      case 'out-of-range':
        return '範囲外の値が指定されています';
      case 'unimplemented':
        return 'この機能はまだ実装されていません';
      case 'internal':
        return 'サーバーでエラーが発生しました。\nしばらくしてからお試しください。';
      case 'cancelled':
        return '操作がキャンセルされました';
      case 'data-loss':
        return 'データが失われました';
      default:
        return 'エラーが発生しました: ${error.message ?? error.code}';
    }
  }

  /// Firestoreエラーメッセージを取得
  static String _getFirestoreErrorMessage(FirebaseException error) {
    return _getFirebaseErrorMessage(error);
  }

  /// SnackBarでエラーメッセージを表示
  static void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    final message = getErrorMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: AppColors.errorSnackBar,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: '再試行',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// 成功メッセージをSnackBarで表示
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: AppColors.successSnackBar,
        duration: duration,
      ),
    );
  }

  /// 情報メッセージをSnackBarで表示
  static void showInfoSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: AppColors.infoSnackBar,
        duration: duration,
      ),
    );
  }

  /// 警告メッセージをSnackBarで表示
  static void showWarningSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: AppColors.warningSnackBar,
        duration: duration,
      ),
    );
  }
}
