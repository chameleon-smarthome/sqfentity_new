// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../sqfentity_gen.dart';

class Imports {
  static Map<String, bool> importedModels = <String, bool>{};
  static List<String> controllers = <String>[];
}

class SqfEntityFormGenerator extends GeneratorForAnnotation<SqfEntityBuilder> {
  @override
  String? generateForAnnotatedElement(Element2 element, ConstantReader annotation, BuildStep buildStep) {
    final model = annotation.read('model').objectValue;

    var instanceName = 'SqfEntityTable';
    instanceName = toCamelCase(instanceName);

    final builder = SqfEntityModelBuilder(model, instanceName);
    print('-------------------------------------------------------FormBuilder: $instanceName');
    final dbModel = builder.toModel();

    if (dbModel.formTables?.isEmpty ?? true) {
      return null;
    }

    final modelStr = StringBuffer();
    final path = buildStep.inputId.uri.pathSegments.last;

    if (dbModel.ignoreForFile != null && dbModel.ignoreForFile!.isNotEmpty) {
      modelStr.writeln('// ignore_for_file: ${dbModel.ignoreForFile!.join(', ')}');
    }

    modelStr.writeln('part of \'$path\';');

    for (final table in dbModel.formTables!) {
      modelStr.writeln(SqfEntityFormConverter(table).toFormWidgetsCode());
    }

    if (Imports.importedModels[path] != null) {
      return null;
    } else {
      Imports.importedModels[path] = true;
      return modelStr.toString();
    }
  }
}