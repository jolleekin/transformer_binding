library transformer_binding;

import 'dart:html';
import 'package:polymer/polymer.dart';

/// Exposes the APIs as a Polymer behavior.
abstract class TransformerBindingBehavior {
  void ready() => setUpTransformerBindings(this as PolymerElement);
}

abstract class Transformer<S, T> {
  /// Converts [input] from host to child.
  T forward(S input);

  /// Converts [input] from child to host.
  S reverse(T input);

  /// The inverse transformer.
  Transformer<T, S> get inverse => new _InverseTransformer<T, S>(this);
}

class _InverseTransformer<T, S> implements Transformer<T, S> {
  Transformer<S, T> _t;
  _InverseTransformer(this._t);

  S forward(T input) => _t.reverse(input);
  T reverse(S input) => _t.forward(input);
  Transformer<S, T> get inverse => _t;
}

typedef PropertyGetter(object);
typedef void PropertySetter(object, value);

/// The map of available transformers, customizable by users.
///
/// Keys are the transformer names that will be used in the binding expressions.
/// For future compatibility, transformer names should be valid identifiers.
final Map<String, Transformer> transformers = <String, Transformer>{};

/// The map of available property getters, customizable by users.
///
/// Keys are property names.
final Map<String, PropertyGetter> propertyGetters = <String, PropertyGetter>{
  'value': (object) => object.value
};

/// The map of available property setters, customizable by users.
///
/// Keys are property names.
final Map<String, PropertySetter> propertySetters = <String, PropertySetter>{
  'text': (object, value) => object.text = value,
  'value': (object, value) => object.value = value
};

/// Sets up the bindings for all elements in [host.root].
///
/// Examples:
/// 1. Two-way binding with explicit event name
///
///     <my-element target-prop="{%host.path|transformer-name::target-event-name%}">
///
/// 2. Two-way binding with default event name
///
///     <my-element target-prop="{%host.path|transformer-name%}">
///     which is equivalent to
///     <my-element target-prop="{%host.path|transformer-name::target-prop-changed%}">
///
/// 3. One-way binding
///
///     <span>[%host.path | transformer-name%]</span>
///     <my-element target-prop="[%host.path | transformer-name%]">
///
void setUpTransformerBindings(PolymerElement host) {
  for (var e in Polymer.dom(host.root).children) {
    _parse(host, e);
  }
}

/// Sets up a single binding between [host] and [child].
void bind(PolymerElement host, String hostPath, Element child,
    String childProperty, Transformer transformer,
    [String childEventName]) {
  var setter = propertySetters[childProperty];

  // Initial value.
  var value = transformer.forward(host.get(hostPath));
  setter(child, value);

  // Host to child.
  var hostEventName = hostPath.split('.')[0] + '-changed';
  host.on[hostEventName].listen((event) {
    // If the root property itself is changed, [changedPath] will be `null`.
    var changedPath = event.detail['path'];
    if (changedPath == null || changedPath == hostPath) {
      var hostValue = host.get(hostPath);
      setter(child, transformer.forward(hostValue));
    }
  });

  // Child to host.
  var getter = propertyGetters[childProperty];
  if (getter != null && childEventName != null) {
    child.on[childEventName].listen((event) {
      var childValue = getter(event.target);
      host.set(hostPath, transformer.reverse(childValue));
    });
  }
}

void _parse(PolymerElement host, Element child) {
  // Parse attributes.
  child.attributes.forEach((name, value) {
      _parseAttribute(host, child, name, value);
  });

  // Parse text content.
  if (child.firstChild == child.lastChild && child.firstChild is Text) {
    _parseAttribute(host, child, 'text', child.text);
  }

  // Parse children.
  for (var e in child.children) {
    _parse(host, e);
  }
}

void _parseAttribute(
    PolymerElement host, Element child, String name, String value) {
  var twoWay = true;
  var match = _twoWaySyntax.firstMatch(value);
  if (match == null) {
    twoWay = false;
    match = _oneWaySyntax.firstMatch(value);
  }
  if (match != null) {
    var s = match[1].replaceAll(' ', '');
    var i = s.indexOf('|');
    var j = s.indexOf('::');
    if (j < 0) j = null;
    var hostPath = s.substring(0, i);
    var transformer = transformers[s.substring(i + 1, j)];
    var childEventName =
        (j != null) ? s.substring(j + 2) : (twoWay ? '$name-changed' : null);
    child.attributes.remove(name);
    bind(host, hostPath, child, name, transformer, childEventName);
  }
}

final RegExp _twoWaySyntax = new RegExp(r'^\{%(.+)%\}$');
final RegExp _oneWaySyntax = new RegExp(r'^\[%(.+)%\]$');
