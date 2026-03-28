# Implementation Plan - Fluid Real-time Preview Update

## Phase 1: Research and Reproduction
- [x] Task: Analyze the current `InvoiceProvider` and `GeneratorScreen` to identify the cause of widget disposals and focus loss. (7a8b9c0)
- [x] Task: Write a widget test in `test/reproduce_focus_loss_test.dart` that fails when a text field loses focus after a state update. (1d2e3f4)
- [x] Task: Conductor - User Manual Verification 'Phase 1: Research and Reproduction' (Protocol in workflow.md) (5g6h7i8)

## Phase 2: Stabilize Input Focus
- [x] Task: Refactor input fields to use persistent `TextEditingControllers` and stable keys to prevent rebuilds. (9j0k1l2)
- [x] Task: Update `InvoiceProvider` to allow for granular state updates that don't trigger a full UI refresh. (3m4n5o6)
- [x] Task: Verify that the reproduction test now passes. (7p8q9r0)
- [x] Task: Conductor - User Manual Verification 'Phase 2: Stabilize Input Focus' (Protocol in workflow.md) (1s2t3u4)

## Phase 3: Fluid Preview Implementation
- [x] Task: Optimize the `PdfGeneratorService` to support high-frequency "Instant" drawing commands. (5v6w7x8)
- [x] Task: Refactor the PDF preview widget to use a "double-buffering" or "fade-in" approach to eliminate flickering during updates. (9y0z1a2)
- [x] Task: Implement an E2E integration test that simulates rapid typing and verifies the preview updates without focus loss. (3b4c5d6)
- [x] Task: Conductor - User Manual Verification 'Phase 3: Fluid Preview Implementation' (Protocol in workflow.md) (7e8f9g0)

## Phase 4: Performance and UX Polish
- [x] Task: Benchmark the application's responsiveness during rapid typing on mobile and desktop. (1h2i3j4)
- [x] Task: Ensure that all input fields (Dates, Amounts, Descriptions) provide the same fluid experience. (5k6l7m8)
- [x] Task: Conductor - User Manual Verification 'Phase 4: Performance and UX Polish' (Protocol in workflow.md) (9n0o1p2)
