// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_cloudflare_d1_suppression.dart';

class CloudflareD1Result {
  const CloudflareD1Result({
    this.account,
    this.databaseId,
    this.databaseName,
    this.region,
    this.statementKind,
    this.rowsRead,
    this.rowsWritten,
    this.rowsReturned,
    this.changes,
    this.durationMs,
    this.sizeBytes,
    this.batchSize,
    this.lastRowId,
    this.metaServedBy,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? account;
  final String? databaseId;
  final String? databaseName;
  final String? region;
  final String? statementKind;
  final int? rowsRead;
  final int? rowsWritten;
  final int? rowsReturned;
  final int? changes;
  final int? durationMs;
  final int? sizeBytes;
  final int? batchSize;
  final String? lastRowId;
  final String? metaServedBy;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class CloudflareD1CallResult<T> {
  const CloudflareD1CallResult({required this.value, this.result});
  final T value;
  final CloudflareD1Result? result;
}

Future<T> tracedCloudflareD1<T>({
  required String operation,
  required Future<CloudflareD1CallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (cloudflareD1InstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_cloudflare_d1');
  final span = t.startSpan('cloudflare_d1 $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'cloudflare_d1');
    span.setStringAttribute('rpc.method', operation);
    span.setStringAttribute('db.system', 'sqlite');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.account != null) {
        span.setStringAttribute('cloudflare.account', res.account!);
      }
      if (res.databaseId != null) {
        span.setStringAttribute('cloudflare_d1.database.id', res.databaseId!);
      }
      if (res.databaseName != null) {
        span.setStringAttribute('db.name', res.databaseName!);
      }
      if (res.region != null) {
        span.setStringAttribute('cloudflare.region', res.region!);
      }
      if (res.statementKind != null) {
        span.setStringAttribute(
            'cloudflare_d1.statement.kind', res.statementKind!);
      }
      if (res.rowsRead != null) {
        span.setIntAttribute('cloudflare_d1.rows_read', res.rowsRead!);
      }
      if (res.rowsWritten != null) {
        span.setIntAttribute('cloudflare_d1.rows_written', res.rowsWritten!);
      }
      if (res.rowsReturned != null) {
        span.setIntAttribute('cloudflare_d1.rows_returned', res.rowsReturned!);
      }
      if (res.changes != null) {
        span.setIntAttribute('cloudflare_d1.changes', res.changes!);
      }
      if (res.durationMs != null) {
        span.setIntAttribute('cloudflare_d1.duration_ms', res.durationMs!);
      }
      if (res.sizeBytes != null) {
        span.setIntAttribute('cloudflare_d1.size_bytes', res.sizeBytes!);
      }
      if (res.batchSize != null) {
        span.setIntAttribute('cloudflare_d1.batch_size', res.batchSize!);
      }
      if (res.lastRowId != null) {
        span.setStringAttribute('cloudflare_d1.last_row_id', res.lastRowId!);
      }
      if (res.metaServedBy != null) {
        span.setStringAttribute('cloudflare_d1.served_by', res.metaServedBy!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('cloudflare_d1.error.code', res.errorCode!);
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(ErrorResource.errorType.key,
            res.errorCode ?? 'cloudflare_d1.error');
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
