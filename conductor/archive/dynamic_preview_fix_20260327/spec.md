# Specification - Dynamic PDF Preview Fix & E2E Testing

This track addresses the issue where the real-time PDF preview remains static and does not update as the user modifies form fields. It also adds end-to-end (E2E) integration testing to ensure the long-term reliability of this feature.

## Problem Statement
The current implementation of the real-time preview in `InvoiceProvider` and `InvoiceScreen` is not successfully triggering or displaying updates during user interaction. Specifically, no loading indicator appears, and the preview content remains unchanged from its initial state.

## User Requirements
- **As a freelancer,** I want to see the PDF preview update automatically and smoothly as I edit invoice details (Description, Total, etc.).
- **As a freelancer,** I want a clear visual indication (loading spinner) that the preview is being updated so I know the system is responsive.

## Proposed Changes

### 1. InvoiceProvider (State Management)
- **Fix Debounce Logic:** Ensure `_generatePreview` correctly initiates the update cycle.
- **Immediate Feedback:** Move the `_isPreviewLoading = true` and the first `notifyListeners()` call *outside* the `Timer` but within `_generatePreview` to provide instant visual feedback (the spinner) before the 500ms delay begins.
- **Error Handling:** Add proper logging/error handling inside `_generatePreview` to ensure silent failures (e.g., PDF generation errors) are caught and reported.

### 2. InvoiceScreen (UI Integration)
- **Optimize Rebuilds:** Review `_onProviderUpdate` and the `setState` logic to ensure it doesn't interfere with the `TextField` focus or the `InvoiceProvider`'s ability to trigger preview updates.
- **Direct Binding:** Ensure all fields (`Description`, `Total`, `Bill To`, `Ship To`, `Currency`, `Date`, `Invoice Number`) are correctly calling their respective update methods in `InvoiceProvider`.

### 3. InvoicePreview (Widget)
- **Refresh Strategy:** Ensure the `SfPdfViewer` widget correctly identifies when `previewBytes` has changed. Using a more robust `ValueKey` (e.g., combining length, a portion of the hash, and a timestamp) may be necessary to force a redraw.

### 4. End-to-End (E2E) Integration Testing
- **New Integration Test:** Create an E2E test file (`integration_test/pdf_preview_e2e_test.dart`) that:
    - Launches the application.
    - Simulates user input in the "Description" field.
    - Verifies that the loading spinner appears.
    - Waits for the debounce period.
    - Verifies that the preview content is refreshed (e.g., by checking if the PDF viewer widget is present and updated).
- **Environment Setup:** Add `integration_test` as a dev dependency and configure the project for running integration tests.

## Acceptance Criteria
- [ ] Typing in the "Description" field triggers the loading spinner in the preview area.
- [ ] After the debounce period (500ms), the PDF preview updates with the new text.
- [ ] Changing the "Total Amount" or "Currency" updates the preview accordingly.
- [ ] Selecting a new "Date" updates the preview.
- [ ] Updating "Bill To" or "Ship To" updates the preview.
- [ ] The "Loading" spinner appears immediately upon typing and disappears once the new preview is rendered.
- [ ] **E2E Test Success:** The newly created integration test suite passes reliably on a mobile/web emulator.

## Out of Scope
- Performance optimization beyond basic responsiveness (e.g., multi-threading/isolates).
- UI redesign of the preview or form.
