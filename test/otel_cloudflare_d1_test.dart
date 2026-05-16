// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_cloudflare_d1/otel_cloudflare_d1.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_cloudflare_d1-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('execute records rows + duration + statement kind', () async {
    await tracedCloudflareD1<String>(
      operation: 'execute',
      invoke: () async => const CloudflareD1CallResult(
        value: 'ok',
        result: CloudflareD1Result(
          databaseName: 'app',
          statementKind: 'query',
          rowsRead: 100,
          rowsReturned: 25,
          durationMs: 12,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('cloudflare_d1 execute')!);
    expect(a['db.system'], 'sqlite');
    expect(a['cloudflare_d1.statement.kind'], 'query');
    expect(a['cloudflare_d1.rows_read'], 100);
  });

  test('error code sets span error', () async {
    await tracedCloudflareD1<String>(
      operation: 'execute',
      invoke: () async => const CloudflareD1CallResult(
        value: 'ok',
        result: CloudflareD1Result(
          errorCode: 'D1_ERROR',
          statusCode: 500,
        ),
      ),
    );
    expect(
      spans.findSpanByName('cloudflare_d1 execute')!.status,
      SpanStatusCode.Error,
    );
  });

  test('batch records batch size', () async {
    await tracedCloudflareD1<String>(
      operation: 'batch',
      invoke: () async => const CloudflareD1CallResult(
        value: 'ok',
        result: CloudflareD1Result(batchSize: 50, changes: 50),
      ),
    );
    final a = attrsOf(spans.findSpanByName('cloudflare_d1 batch')!);
    expect(a['cloudflare_d1.batch_size'], 50);
    expect(a['cloudflare_d1.changes'], 50);
  });

  test('suppression skips spans', () async {
    await runWithoutCloudflareD1InstrumentationAsync(() async {
      await tracedCloudflareD1<String>(
        operation: 'execute',
        invoke: () async => const CloudflareD1CallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('cloudflare_d1 '), isEmpty);
  });
}
