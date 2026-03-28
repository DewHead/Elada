# Implementation Plan - Fluid Real-time Preview Update

## Phase 1: Research and Reproduction
- [ ] Task: Analyze the current `InvoiceProvider` and `GeneratorScreen` to identify the cause of widget disposals and focus loss.
- [ ] Task: Write a widget test in `test/reproduce_focus_loss_test.dart` that fails when a text field loses focus after a state update.
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Research and Reproduction' (Protocol in workflow.md)

## Phase 2: Stabilize Input Focus
- [ ] Task: Refactor input fields to use persistent `TextEditingControllers` and stable keys to prevent rebuilds.
- [ ] Task: Update `InvoiceProvider` to allow for granular state updates that don't trigger a full UI refresh.
- [ ] Task: Verify that the reproduction test now passes.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Stabilize Input Focus' (Protocol in workflow.md)

## Phase 3: Fluid Preview Implementation
- [ ] Task: Optimize the `PdfGeneratorService` to support high-frequency "Instant" drawing commands.
- [ ] Task: Refactor the PDF preview widget to use a "double-buffering" or "fade-in" approach to eliminate flickering during updates.
- [ ] Task: Implement an E2E integration test that simulates rapid typing and verifies the preview updates without focus loss.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Fluid Preview Implementation' (Protocol in workflow.md)

## Phase 4: Performance and UX Polish
- [ ] Task: Benchmark the application's responsiveness during rapid typing on mobile and desktop.
- [ ] Task: Ensure that all input fields (Dates, Amounts, Descriptions) provide the same fluid experience.
- [ ] Task: Conductor - User Manual Verification 'Phase 4: Performance and UX Polish' (Protocol in workflow.md)
