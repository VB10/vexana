/// Platforma özgü bağlantı kontrolü sözleşmesi.
/// For io and web
///
/// IO tarafında DNS çözümlemesi / ağ arayüzü kontrolü, web tarafında
/// `navigator.onLine` ile karşılanır.
mixin CustomNetworkCheck {
  /// [host] verilirse o ana bilgisayarın gerçekten çözümlenip
  /// çözümlenmediğine bakılır. Verilmezse cihazda kullanılabilir bir ağ
  /// bağlantısı olup olmadığı kontrol edilir.
  ///
  /// [timeout] süresi aşılırsa `false` döner — kontrol hiçbir koşulda
  /// çağıranı süresiz bekletmez.
  Future<bool> isReachable({required Duration timeout, String? host});
}
