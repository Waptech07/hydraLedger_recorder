import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';
import 'package:voice_recorder/botton_nav_bar.dart';

class MyBannerAdWidget extends StatefulWidget {
  final Widget? screen;
  final bool shouldNavigate;
  final void Function()? callback;

  final AdSize adSize;
  final String adUnitId = Platform.isAndroid
      ? 'ca-app-pub-2920822568389403/5302797791'
      : 'ca-app-pub-2920822568389403/5494369483';

  MyBannerAdWidget({
    super.key,
    this.adSize = AdSize.mediumRectangle,
    this.screen,
    this.shouldNavigate = true,
    this.callback,
  });

  @override
  State<MyBannerAdWidget> createState() => _MyBannerAdWidgetState();
}

class _MyBannerAdWidgetState extends State<MyBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  Timer? _navigationTimer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: widget.adSize.width.toDouble(),
        height: widget.adSize.height.toDouble(),
        child: _isAdLoaded
            ? AdWidget(ad: _bannerAd!)
            : Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _loadAd() {
    final bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Ad was loaded successfully: $ad');
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isAdLoaded = true;
          });
          _startNavigationTimer();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
          _handleAdFailure();
        },
        onAdClosed: (ad) {
          widget.callback!();
        },
      ),
    );

    bannerAd.load();
  }

  void _startNavigationTimer() {
    _navigationTimer = Timer(const Duration(seconds: 5), () {
      if (widget.shouldNavigate) {
        _navigateToNextPage();
      } else if (widget.callback != null) {
        widget.callback!();
      }
    });
  }

  void _handleAdFailure() {
    // Option 1: Retry loading the ad
    _retryLoadingAd();

    // Option 2: Navigate to the next page immediately
    // _navigateToNextPage();

    // Option 3: Show a placeholder and navigate after a delay
    // _showPlaceholderAndNavigate();
  }

  void _retryLoadingAd() {
    // Wait for a short duration before retrying
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _loadAd();
      }
    });
  }

  void _showPlaceholderAndNavigate() {
    setState(() {
      _isAdLoaded = true; // This will show a placeholder instead of shimmer
    });
    _startNavigationTimer();
  }

  void _navigateToNextPage() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => widget.screen ?? AppBottomNavBar(),
        ),
      );
    }
  }
}
