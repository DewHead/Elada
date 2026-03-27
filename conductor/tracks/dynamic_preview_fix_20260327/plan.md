# Implementation Plan - Dynamic PDF Preview Fix & E2E Testing

This plan addresses the static PDF preview issue and adds end-to-end (E2E) integration testing.

## Phase 1: Environment Setup & Foundation
- [x] Task: Add `integration_test` to `dev_dependencies` in `pubspec.yaml`. 75fd39a
- [x] Task: Create initial E2E test structure in `integration_test/pdf_preview_e2e_test.dart`. 75b9ea9
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Environment Setup & Foundation' (Protocol in workflow.md)

## Phase 2: InvoiceProvider Fix (TDD)
- [ ] Task: Write failing unit tests in `test/presentation/providers/invoice_provider_preview_test.dart` to reproduce the static preview bug (verify that `notifyListeners` is called and `isPreviewLoading` is set correctly).
- [ ] Task: Implement fix in `lib/presentation/providers/invoice_provider.dart`:
    - Move `_isPreviewLoading = true` and `notifyListeners()` outside the `Timer`.
    - Ensure all field update methods trigger `_generatePreview`.
- [ ] Task: Verify unit tests pass and coverage is >80% for `InvoiceProvider`.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: InvoiceProvider Fix' (Protocol in workflow.md)

## Phase 3: UI & Widget Integration (TDD)
- [ ] Task: Write failing widget tests in `test/presentation/widgets/invoice_preview_test.dart` to verify that the loading spinner appears immediately and the PDF viewer updates when `previewBytes` changes.
- [ ] Task: Update `lib/presentation/widgets/invoice_preview.dart`:
    - Refine `ValueKey` for `SfPdfViewer.memory` to ensure reliable refreshes.
    - Ensure the loading indicator is correctly positioned and visible.
- [ ] Task: Update `lib/presentation/screens/invoice_screen.dart`:
    - Ensure all `TextField` `onChanged` callbacks correctly call the provider.
- [ ] Task: Verify widget tests pass and coverage is >80% for the preview components.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: UI & Widget Integration' (Protocol in workflow.md)

## Phase 4: End-to-End (E2E) Verification
- [ ] Task: Complete the E2E test in `integration_test/pdf_preview_e2e_test.dart` as specified.
- [ ] Task: Run the E2E test suite and verify it passes.
- [ ] Task: Conductor - User Manual Verification 'Phase 4: End-to-End (E2E) Verification' (Protocol in workflow.md)
