import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:smart_books/services/storage_service.dart';
import 'package:get_it/get_it.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  // ストレージサービス（設定の保存に使用）
  late StorageService _storageService;
  
  // 通知が有効かどうか
  bool _notificationsEnabled = true;
  
  NotificationService() {
    _storageService = GetIt.instance<StorageService>();
  }
  
  // 通知サービスの初期化
  Future<void> init() async {
    // タイムゾーンの初期化
    tz_data.initializeTimeZones();
    
    // 設定から通知の有効/無効を読み込む
    _notificationsEnabled = _storageService.areNotificationsEnabled();
    
    // プラットフォームごとの設定
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );
    
    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    // 通知プラグインの初期化
    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
    
    // iOSの通知権限をリクエスト
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
    
    // Androidの通知チャンネルを作成
    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_mainChannel);
      
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_reminderChannel);
      
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_updateChannel);
    }
  }
  
  // メイン通知チャンネル（一般的な通知）
  final AndroidNotificationChannel _mainChannel = const AndroidNotificationChannel(
    'main_channel',
    '一般通知',
    description: '一般的なアプリからの通知',
    importance: Importance.high,
  );
  
  // リマインダー通知チャンネル
  final AndroidNotificationChannel _reminderChannel = const AndroidNotificationChannel(
    'reminder_channel',
    'リマインダー',
    description: '期限や予定のリマインダー',
    importance: Importance.high,
  );
  
  // 更新通知チャンネル
  final AndroidNotificationChannel _updateChannel = const AndroidNotificationChannel(
    'update_channel',
    'アップデート',
    description: 'アプリのアップデートや新機能の通知',
    importance: Importance.low,
  );
  
  // iOS通知受信コールバック（iOSのみ）
  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    // 必要に応じて実装（iOS 10未満のみ）
  }
  
  // 通知タップ時のコールバック
  void _onDidReceiveNotificationResponse(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload != null) {
      print('通知がタップされました！ペイロード: $payload');
      // ペイロードに基づいて適切な画面に遷移するなどの処理を実装
    }
  }
  
  // 通知の有効/無効を切り替え
  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    await _storageService.setNotificationsEnabled(enabled);
  }
  
  // 通知の有効状態を取得
  bool get isNotificationsEnabled => _notificationsEnabled;
  
  // 即時通知を表示
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelType = 'main',
  }) async {
    if (!_notificationsEnabled) return;
    
    // チャンネルの選択
    AndroidNotificationChannel channel;
    switch (channelType) {
      case 'reminder':
        channel = _reminderChannel;
        break;
      case 'update':
        channel = _updateChannel;
        break;
      default:
        channel = _mainChannel;
        break;
    }
    
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: Priority.high,
      showWhen: true,
    );
    
    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }
  
  // 予定通知を設定
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelType = 'reminder',
  }) async {
    if (!_notificationsEnabled) return;
    
    // チャンネルの選択
    AndroidNotificationChannel channel;
    switch (channelType) {
      case 'update':
        channel = _updateChannel;
        break;
      default:
        channel = _reminderChannel;
        break;
    }
    
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: Priority.high,
      showWhen: true,
    );
    
    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
  
  // 定期通知を設定
  Future<void> schedulePeriodicNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval interval,
    String? payload,
    String channelType = 'reminder',
  }) async {
    if (!_notificationsEnabled) return;
    
    // チャンネルの選択
    AndroidNotificationChannel channel;
    switch (channelType) {
      case 'update':
        channel = _updateChannel;
        break;
      default:
        channel = _reminderChannel;
        break;
    }
    
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: Priority.high,
      showWhen: true,
    );
    
    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _flutterLocalNotificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      interval,
      platformDetails,
      androidAllowWhileIdle: true,
      payload: payload,
    );
  }
  
  // 特定の通知をキャンセル
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
  
  // すべての通知をキャンセル
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
  
  // 確定申告のリマインダーを設定（例：1月、2月、3月の通知）
  Future<void> setTaxFilingReminders(int year) async {
    if (!_notificationsEnabled) return;
    
    // 1月1日のリマインダー（確定申告準備）
    await scheduleNotification(
      id: 1001,
      title: '確定申告の準備を始めましょう',
      body: '${year}年の確定申告に向けて書類の準備を始める時期です。財Techで事前準備を始めましょう。',
      scheduledDate: DateTime(year, 1, 1, 9, 0),
      payload: 'tax_filing_preparation',
    );
    
    // 2月中旬のリマインダー
    await scheduleNotification(
      id: 1002,
      title: '確定申告の提出期限が近づいています',
      body: '確定申告の提出期限まであと1ヶ月です。財Techで申告書の作成を進めましょう。',
      scheduledDate: DateTime(year, 2, 15, 9, 0),
      payload: 'tax_filing_reminder',
    );
    
    // 3月10日の最終リマインダー
    await scheduleNotification(
      id: 1003,
      title: '確定申告の提出期限が迫っています',
      body: '確定申告の提出期限まであと5日です。財Techで最終確認を行いましょう。',
      scheduledDate: DateTime(year, 3, 10, 9, 0),
      payload: 'tax_filing_deadline',
    );
  }
  
  // 毎月の経費入力リマインダーを設定
  Future<void> setMonthlyExpenseReminder() async {
    if (!_notificationsEnabled) return;
    
    // 毎月1日にリマインダーを表示
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1, 9, 0);
    
    await scheduleNotification(
      id: 2001,
      title: '先月の経費を入力しましょう',
      body: '先月の経費をまとめて入力する時期です。財Techで簡単に経費管理を行いましょう。',
      scheduledDate: nextMonth,
      payload: 'monthly_expense',
    );
  }
  
  // 請求書支払いのリマインダーを設定
  Future<void> setInvoicePaymentReminder({
    required int id,
    required String title,
    required DateTime dueDate,
    required double amount,
  }) async {
    if (!_notificationsEnabled) return;
    
    // 支払期限の3日前
    final reminderDate = dueDate.subtract(const Duration(days: 3));
    final now = DateTime.now();
    
    if (reminderDate.isAfter(now)) {
      await scheduleNotification(
        id: id,
        title: '請求書の支払い期限が近づいています',
        body: '$title: ¥${amount.toStringAsFixed(0)}の支払い期限は${_formatDate(dueDate)}です。',
        scheduledDate: reminderDate,
        payload: 'invoice_payment_$id',
      );
    }
  }
  
  // 日付フォーマット用ヘルパーメソッド
  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
  
  // 消費税申告のリマインダーを設定（例：四半期ごと）
  Future<void> setConsumptionTaxReminders(int year) async {
    if (!_notificationsEnabled) return;
    
    // 第1四半期（4月末）
    await scheduleNotification(
      id: 3001,
      title: '第1四半期の消費税申告準備',
      body: '第1四半期の消費税申告の準備を始める時期です。財Techで簡単に消費税の計算を行いましょう。',
      scheduledDate: DateTime(year, 4, 20, 9, 0),
      payload: 'consumption_tax_q1',
    );
    
    // 第2四半期（7月末）
    await scheduleNotification(
      id: 3002,
      title: '第2四半期の消費税申告準備',
      body: '第2四半期の消費税申告の準備を始める時期です。財Techで簡単に消費税の計算を行いましょう。',
      scheduledDate: DateTime(year, 7, 20, 9, 0),
      payload: 'consumption_tax_q2',
    );
    
    // 第3四半期（10月末）
    await scheduleNotification(
      id: 3003,
      title: '第3四半期の消費税申告準備',
      body: '第3四半期の消費税申告の準備を始める時期です。財Techで簡単に消費税の計算を行いましょう。',
      scheduledDate: DateTime(year, 10, 20, 9, 0),
      payload: 'consumption_tax_q3',
    );
    
    // 第4四半期（翌年1月末）
    await scheduleNotification(
      id: 3004,
      title: '第4四半期の消費税申告準備',
      body: '第4四半期の消費税申告の準備を始める時期です。財Techで簡単に消費税の計算を行いましょう。',
      scheduledDate: DateTime(year + 1, 1, 20, 9, 0),
      payload: 'consumption_tax_q4',
    );
  }
  
  // ふるさと納税のリマインダーを設定（12月初旬）
  Future<void> setHometownTaxReminder(int year) async {
    if (!_notificationsEnabled) return;
    
    await scheduleNotification(
      id: 4001,
      title: 'ふるさと納税の検討時期です',
      body: '今年のふるさと納税はお済みですか？年末までの寄付で今年度の税控除が受けられます。財Techでシミュレーションしましょう。',
      scheduledDate: DateTime(year, 12, 1, 9, 0),
      payload: 'hometown_tax',
    );
  }
  
  // アプリ更新通知
  Future<void> showAppUpdateNotification({
    required String version,
    required String features,
  }) async {
    if (!_notificationsEnabled) return;
    
    await showNotification(
      id: 5001,
      title: '財Tech がアップデートされました',
      body: 'バージョン $version にアップデートしました。新機能: $features',
      channelType: 'update',
      payload: 'app_update',
    );
  }
}
