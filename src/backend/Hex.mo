// Local vendored copy of the mops `hex` package (hex@1.0.2), patched for
// `core` 2.x compatibility.
//
// The upstream package (mops.one/hex) imports `mo:core/Array`, `mo:core/Text`,
// etc. but was written for the core 1.x API. The core 2.x release renamed
// `Array.vals()` to `Array.values()` and flipped the argument order of
// `Text.join` to method-call style. This local copy uses `mo:base/Array` and
// `mo:base/Text` instead, which still ship the legacy APIs.
//
// Only the surface used by identify is kept: `toText`, `toTextFormat`, and
// the `URL` format constant. The full upstream API is at
// github.com/nomeata/motoko-hex (or mops.one/hex).

import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Char "mo:base/Char";
import Result "mo:base/Result";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Int "mo:base/Int";
import Debug "mo:base/Debug";

module {

  public type Format = {
    pre : Text;
    post : Text;
    sep : Text;
    preItem : Text;
    empty : Text;
    upper : Bool;
  };

  /// A `Format` constant for URL encoding with upper case hex values, "%" prefixes for items.
  public let URL : Format = {
    pre = "";
    post = "";
    sep = "";
    preItem = "%";
    empty = "";
    upper = true;
  };

  /// Convert a byte array to a hex string.
  public func toText(bytes : [Nat8]) : Text {
    let texts = Array.map<Nat8, Text>(bytes, encodeByte);
    return Text.join("", texts.vals());
  };

  /// Convert a byte array to a hex string using a custom format.
  public func toTextFormat(bytes : [Nat8], options : Format) : Text {
    if (bytes == []) return options.empty;
    let encoder = if (options.upper) encodeByteUpper else encodeByte;
    let texts = Array.map<Nat8, Text>(bytes, func(b) { return options.preItem # encoder(b) });
    return options.pre # Text.join(options.sep, texts.vals()) # options.post;
  };

  /// Convert hex Text into a byte array.
  /// Similar to `toArray` but traps if `hex` contains invalid characters
  public func toArrayUnsafe(hex : Text) : [Nat8] {
    switch (toArray(hex)) {
      case (#ok(data)) return data;
      case (#err(msg)) Debug.trap("Hex.toArrayUnsafe: " # msg);
    };
  };

  /// Convert hex Text into a byte array. Returns a Result to signal parse failures.
  public func toArray(hex : Text) : Result.Result<[Nat8], Text> {
    let chars = hex.size();
    if (chars % 2 != 0) return #err("Hex string has odd length");
    let size = chars / 2;
    let charsArr = Text.toArray(hex);
    toArrayHelper(charsArr, 0, size, []);
  };

  func toArrayHelper(charsArr : [Char], i : Nat, size : Nat, acc : [Nat8]) : Result.Result<[Nat8], Text> {
    if (i >= size) return #ok(acc);
    let c0 = charsArr[i * 2];
    let c1 = charsArr[i * 2 + 1];
    switch ((decodeNibble(c0), decodeNibble(c1))) {
      case ((?hi, ?lo)) {
        toArrayHelper(charsArr, i + 1, size, Array.append(acc, [hi * 16 + lo]))
      };
      case (_) {
        #err("Invalid hex character at position " # Int.toText(i * 2))
      };
    };
  };

  /// Decode a single hex character.
  public func decodeNibble(c : Char) : ?Nat8 {
    switch (c) {
      case ('0') { ?0 };
      case ('1') { ?1 };
      case ('2') { ?2 };
      case ('3') { ?3 };
      case ('4') { ?4 };
      case ('5') { ?5 };
      case ('6') { ?6 };
      case ('7') { ?7 };
      case ('8') { ?8 };
      case ('9') { ?9 };
      case ('a') { ?10 };
      case ('b') { ?11 };
      case ('c') { ?12 };
      case ('d') { ?13 };
      case ('e') { ?14 };
      case ('f') { ?15 };
      case ('A') { ?10 };
      case ('B') { ?11 };
      case ('C') { ?12 };
      case ('D') { ?13 };
      case ('E') { ?14 };
      case ('F') { ?15 };
      case (_) { null };
    };
  };

  func encodeByte(byte : Nat8) : Text {
    let high = Nat8.toNat(byte / 16);
    let low = Nat8.toNat(byte % 16);
    encodeNibble(high) # encodeNibble(low);
  };

  func encodeByteUpper(byte : Nat8) : Text {
    let high = Nat8.toNat(byte / 16);
    let low = Nat8.toNat(byte % 16);
    encodeNibbleUpper(high) # encodeNibbleUpper(low);
  };

  func encodeNibble(nibble : Nat) : Text {
    if (nibble < 10) Char.toText(Char.fromNat32(48 + Nat32.fromNat(nibble)))
    else Char.toText(Char.fromNat32(97 + Nat32.fromNat(nibble - 10)))
  };

  func encodeNibbleUpper(nibble : Nat) : Text {
    if (nibble < 10) Char.toText(Char.fromNat32(48 + Nat32.fromNat(nibble)))
    else Char.toText(Char.fromNat32(65 + Nat32.fromNat(nibble - 10)))
  };
}
