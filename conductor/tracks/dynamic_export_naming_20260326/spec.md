# Specification: Dynamic Export Naming

## Overview
This track implements a dynamic naming convention for exported PDF invoices. Instead of a generic filename, the system will now generate a filename based on the invoice's internal "Invoice Number" and "Invoice Date" fields.

## Functional Requirements
- **Dynamic Filename Generation:** When a user exports an invoice, the default filename must follow the pattern: `[InvoiceNumber]_[InvoiceDate].pdf`.
- **Date Formatting:** The "Invoice Date" portion of the filename must use hyphens (`-`) as separators (e.g., `26-03-2026`) to ensure filesystem compatibility.
- **Data Source:** The filename must be derived from the actual values entered in the "INVOICE NO." and "Date" fields within the invoice editor.
- **Export Validation:** 
    - The system must verify that both "INVOICE NO." and "Date" are not empty before allowing an export.
    - If either field is missing, the export should be blocked, and the user should be prompted to provide the missing information.

## Non-Functional Requirements
- **Filesystem Safety:** The filename generation must sanitize any characters in the "Invoice Number" that are illegal for filenames (e.g., `/`, `\`, `:`, `*`, `?`, `"`, `<`, `>`, `|`).

## Acceptance Criteria
- [ ] Exporting an invoice with Number `123` and Date `26/03/2026` results in a file named `123_26-03-2026.pdf`.
- [ ] Attempting to export with an empty Invoice Number triggers a validation message and prevents the file save dialog from appearing.
- [ ] Attempting to export with an empty Date triggers a validation message and prevents the file save dialog from appearing.
- [ ] Illegal characters in the Invoice Number (like `123/A`) are automatically replaced or removed (e.g., `123-A_26-03-2026.pdf`).

## Out of Scope
- Allowing users to manually type a different filename during the export process (the system-generated name is the focus here).
- Changing how dates are displayed *inside* the PDF document itself.
