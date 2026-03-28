# Specification - Fluid Real-time Preview Update

## Overview
The current "Real-time PDF Preview" implementation causes the input fields to lose focus and the preview to flicker or refresh jarringly whenever a user types. This track aims to transition the preview to a truly fluid, "live-edit" experience similar to a browser's DOM inspector, ensuring focus is maintained and updates are seamless across all input fields.

## Functional Requirements
- **Focus Persistence:** Input fields must NOT lose focus or be rebuilt while the user is typing.
- **Keystroke-Level Updates:** The PDF preview must update on every keystroke for all input fields (Description, Amounts, Invoice Number, Date, etc.).
- **Zero-Flicker Rendering:** The transition between preview states must be visually seamless, avoiding "white flashes" or layout shifts.
- **Synchronized State:** All UI fields (Generator) and the Preview (PDF) must remain perfectly synchronized in real-time.

## Non-Functional Requirements
- **Performant Rendering:** Optimize the PDF generation engine to handle high-frequency updates without UI lag on mobile or desktop.
- **State Management Integrity:** Ensure `Provider` updates do not trigger unnecessary widget disposals in the input layer.

## Acceptance Criteria
- [ ] Typing in any field (e.g., Description) updates the PDF preview immediately without requiring the user to click back into the field.
- [ ] The cursor position in the text field remains correct after an update.
- [ ] The PDF viewer does not show a loading indicator or "flash" between keystrokes.
- [ ] CPU/Memory usage remains stable during rapid typing.

## Out of Scope
- Changing the PDF layout or visual identity.
- Modifying the Dashboard or Invoice History logic (unless required for state synchronization).
