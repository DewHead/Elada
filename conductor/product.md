# Product Definition - Elada

## Initial Concept
A system to manage and programmatically generate professional invoices based on the YONIK KOSHER LIFESTYLE LTD visual identity.

## Target Users
- **Individual Freelancers:** Users who need a standardized, professional invoice template they can quickly reuse with updated details for each client or project.

## Project Goals
- **Efficiency & Speed:** Dramatically reduce the time spent manually editing PDF templates by providing a streamlined, automated input process.
- **Operational Accuracy:** Eliminate human error in invoice numbering and balance calculations through automated incrementing and field mapping.
- **Brand Integrity:** Maintain the exact visual fidelity and professional aesthetic of the original YONIK KOSHER LIFESTYLE LTD template across all generated documents.

## Key Features
- **Dynamic Field Injection:** Directly modify the "Description", "Total", "Balance Due", and "Invoice Date" fields via a clean user interface.
- **Smart Invoice Numbering:** Automatically track and increment the "INVOICE NO." while allowing for manual overrides when necessary.
- **PDF Generation Engine:** A programmatic "PDF-from-Code" engine that draws high-quality, pixel-perfect invoices from scratch upon modification.
- **Dashboard & History:** A centralized hub to view all previously generated invoices and manage ongoing drafts, including metadata like the specific date assigned to each invoice.
- **Dynamic Export Naming:** Automatically generates descriptive filenames for exported PDFs using the `[InvoiceNumber]_[InvoiceDate].pdf` pattern, ensuring filesystem compatibility through automatic sanitization.
- **Draft Management:** Full CRUD support for invoice drafts, allowing users to save progress and resume editing at any time.
- **Multi-Currency Support:** Ability to generate invoices in multiple currencies (€, $, £), with automatic formatting and persistence.
- **Real-time PDF Preview:** A live, debounced visual representation of the invoice as fields are updated, with a responsive side-by-side layout for desktop and toggleable view for mobile.
- **Main Navigation:** Modern, intuitive navigation to switch seamlessly between the Generator and the Dashboard.

## Visual Identity
- **Minimalist Aesthetic:** A "less is more" design philosophy featuring generous white space, refined typography, and a clean, uncluttered interface to ensure a premium feel and ease of use.
- **Mobile-Friendly:** The UI is fully responsive, ensuring a seamless experience across desktop, tablet, and mobile devices.

## Non-Functional Requirements
- **Polished UX:** A highly responsive and visually sophisticated UI that feels modern and "alive."
- **Local Portability:** Designed for easy local execution without the need for complex server configurations or dependencies.
