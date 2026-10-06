/// Kullanıcının yazdığı sunucu adresini düzeltir: boşluklar atılır, `http://` ve varsayılan
/// port (8002, panonun portu) eklenir, sondaki `/` kalkar. Boş = sahte veri.
const int sunucuVarsayilanPort = 8002;

String sunucuAdresiDuzelt(String ham) {
  var adres = ham.trim();
  if (adres.isEmpty) return '';
  if (!adres.contains('://')) adres = 'http://$adres';
  adres = adres.replaceAll(RegExp(r'/+$'), '');
  final uri = Uri.tryParse(adres);
  if (uri == null || uri.host.isEmpty) return adres;
  if (!uri.hasPort) adres = '${uri.scheme}://${uri.host}:$sunucuVarsayilanPort${uri.path}';
  return adres.replaceAll(RegExp(r'/+$'), '');
}
