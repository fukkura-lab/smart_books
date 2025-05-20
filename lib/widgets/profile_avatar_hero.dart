import 'package:flutter/material.dart';

// 設定画面のプロフィールセクションで使用するHeroアバターウィジェット
class ProfileAvatarHero extends StatelessWidget {
  final String heroTag;
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;
  
  const ProfileAvatarHero({
    Key? key,
    required this.heroTag,
    this.size = 64,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      // flightShuttleBuilder でアニメーション中の見た目をカスタマイズ
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              width: size * (1 + 0.5 * animation.value),
              height: size * (1 + 0.5 * animation.value),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1 * animation.value),
                    blurRadius: 10 * animation.value,
                    spreadRadius: 2 * animation.value,
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                size: size * 0.5 * (1 + 0.5 * animation.value),
                color: iconColor,
              ),
            );
          },
        );
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: size * 0.5,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

// 設定画面でのプロフィールセクションの例
class SettingsProfileSection extends StatelessWidget {
  const SettingsProfileSection({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/profile');
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // プロフィール画像（Hero アニメーション付き）
                ProfileAvatarHero(
                  heroTag: 'profileAvatar',
                  size: 64,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  iconColor: primaryColor,
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                const SizedBox(width: 16),
                // ユーザー情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'テストユーザー',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'test@example.com',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'プロフィールを編集',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// プロフィール画面でも同じHeroタグを使う例
class ProfileScreenAvatar extends StatelessWidget {
  const ProfileScreenAvatar({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Hero(
      tag: 'profileAvatar',
      child: Stack(
        children: [
          // 画像のプレースホルダー
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 4,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.person,
                size: 64,
                color: primaryColor,
              ),
            ),
          ),
          
          // 編集ボタン
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.white,
                ),
                padding: EdgeInsets.zero,
                onPressed: () {
                  // プロフィール画像変更機能
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}