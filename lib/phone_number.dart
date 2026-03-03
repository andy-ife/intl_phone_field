import 'countries.dart';

class NumberTooLongException implements Exception {}

class NumberTooShortException implements Exception {}

class InvalidCharactersException implements Exception {}

class PhoneNumber {
  String countryISOCode;
  String countryCode;
  String number;

  PhoneNumber({
    required this.countryISOCode,
    required this.countryCode,
    required this.number,
  });

  factory PhoneNumber.fromCompleteNumber({required String completeNumber}) {
    if (completeNumber == "") {
      return PhoneNumber(countryISOCode: "", countryCode: "", number: "");
    }

    try {
      Country country = getCountry(completeNumber);
      String number;
      if (completeNumber.startsWith('+')) {
        number = completeNumber.substring(1 + country.dialCode.length + country.regionCode.length);
      } else {
        number = completeNumber.substring(country.dialCode.length + country.regionCode.length);
      }
      return PhoneNumber(
          countryISOCode: country.code, countryCode: country.dialCode + country.regionCode, number: number);
    } on InvalidCharactersException {
      rethrow;
      // ignore: unused_catch_clause
    } on Exception catch (e) {
      return PhoneNumber(countryISOCode: "", countryCode: "", number: "");
    }
  }

  bool isValidNumber() {
    // Check for countries that share the same dial code, but have different number lengths.
    final formattedNumber = completeNumber.startsWith('+') ? completeNumber.substring(1) : completeNumber;
    if (formattedNumber.startsWith('358') && number.length == 12 || number.length == 15) {
      return true;
    } else if (formattedNumber.startsWith('590') && number.length == 9 || number.length == 15) {
      return true;
    } else if (formattedNumber.startsWith('262') && number.length == 9 || number.length == 15) {
      return true;
    } else if (formattedNumber.startsWith('44') && number.length == 6 || number.length == 10) {
      return true;
    }

    Country country = getCountry(completeNumber);
    if (number.length < country.minLength) {
      throw NumberTooShortException();
    }

    if (number.length > country.maxLength) {
      throw NumberTooLongException();
    }
    return true;
  }

  String get completeNumber {
    return countryCode + number;
  }

  static Country getCountry(String phoneNumber) {
    if (phoneNumber == "") {
      throw NumberTooShortException();
    }

    final validPhoneNumber = RegExp(r'^[+0-9]*[0-9]*$');

    if (!validPhoneNumber.hasMatch(phoneNumber)) {
      throw InvalidCharactersException();
    }

    if (phoneNumber.startsWith('+')) {
      return countries
          .firstWhere((country) => phoneNumber.substring(1).startsWith(country.dialCode + country.regionCode));
    }
    return countries.firstWhere((country) => phoneNumber.startsWith(country.dialCode + country.regionCode));
  }

  @override
  String toString() => 'PhoneNumber(countryISOCode: $countryISOCode, countryCode: $countryCode, number: $number)';
}
