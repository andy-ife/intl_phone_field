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
    final formattedNumber = completeNumber.startsWith('+') ? completeNumber.substring(1) : completeNumber;
    // Find all countries that match the dial code (some share the same code
    // but have different valid number lengths, e.g. +44, +262, +358, +590).
    final matchingCountries =
        countries.where((country) => formattedNumber.startsWith(country.dialCode + country.regionCode));

    if (matchingCountries.isEmpty) {
      throw NumberTooShortException();
    }

    // If any matching country considers the number length valid, accept it.
    final isValid = matchingCountries.any(
      (country) {
        return number.length >= country.minLength && number.length <= country.maxLength;
      },
    );

    if (isValid) return true;

    if (matchingCountries.every((country) => number.length < country.minLength)) {
      throw NumberTooShortException();
    } else if (matchingCountries.every((country) => number.length > country.maxLength)) {
      throw NumberTooLongException();
    } else {
      throw InvalidCharactersException();
    }
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
