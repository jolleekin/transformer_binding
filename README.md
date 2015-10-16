# Overview
A custom binding syntax built on top of
[polymer](https://pub.dartlang.org/packages/polymer) that supports transformers.

# Usage
## Register a property for binding
By default, **transformer_binding** supports binding for the following properties
- `text` (one way)
- `value` (two way)

To enable binding for other properties, users must register setters and,
optionally, getters for those properties
- Register both setters and getters to enable one way binding and two way binding
- Register setters only to enable one way binding

Example:
```` dart
import 'package:transformer_binding/transformer_binding.dart';

main() {
  // Register the property setter for host-to-child binding (one way binding).
  propertySetters['target-prop'] = (object, value) => object.targetProp = value;

  // Register the property getter for child-to-host binding.
  // This is optional, only required for two way binding.
  propertyGetters['target-prop'] = (object) => object.targetProp;
}
````
## Register transformers
**transformer_binding** comes with no predefined transformers.
Users have to create and register their own transformers.

Example:
```` dart
import 'package:intl/intl.dart';
import 'package:polymer/polymer.dart';
import 'package:transformer_binding/transformer_binding.dart';

/// A transformer that converts an integer to a nicely formatted string (which
/// contains thousands separators) and vice versa. Invalid inputs will be
/// converted to `null`.
class IntToStringTransformer extends Transformer<int, String> {
  final NumberFormat _formatter;

  /// See [NumberFormat.decimalPattern].
  IntToStringTransformer([String locale])
      : _formatter = new NumberFormat.decimalPattern(locale);

  @override
  String forward(int input) {
    return (input != null) ? _formatter.format(input) : '';
  }

  @override
  int reverse(String input) {
    try {
      return _formatter.parse(input).toInt();
    } catch (_) {
      return null;
    }
  }
}

main() async {
  // Register the transformer under the name 'intToString'.
  transformers['intToString'] = new IntToStringTransformer();
  
  await initPolymer();
}
````
## Binding syntax
The binding syntax is pretty much the same as that of
[polymer](https://pub.dartlang.org/packages/polymer) except for the added
`|transformer-name` token and the different mustaches.
1. Two-way binding with explicit event name
```` html
    <my-element target-prop="{%host.path|transformer-name::target-event-name%}">
````
2. Two-way binding with default event name
```` html
    <my-element target-prop="{%host.path|transformer-name%}">
    
    which is equivalent to
    
    <my-element target-prop="{%host.path|transformer-name::target-prop-changed%}">
````
3. One-way binding
```` html
    <span>[%host.path | transformer-name%]</span>
    
    <my-element target-prop="[%host.path | transformer-name%]">
````