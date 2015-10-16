// Copyright (c) 2015, Man Hoang. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library custom_binding.test.index;

import 'package:polymer/polymer.dart';
import 'package:transformer_binding/transformer_binding.dart';
import 'product_element.dart';
import 'transformers.dart';

main() async {
  transformers['intToString'] = new IntToStringTransformer();
  transformers['currencyToString'] = new CurrencyToStringTransformer();
  await initPolymer();
}
