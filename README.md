# Alka IVF — Digital Hospital Platform (development starter)

A connected frontend and backend starter based on the uploaded **IVF Hospital Digital Platform | Product and Technical Specification** (28 pages, October 2026). It includes the public website, demo patient portal, staff workspace and a role-checked REST API.

> **Important clinical and privacy boundary**
>
> This repository is a development/demo starter, **not a production-ready clinical information system**. It ships with synthetic records and demonstration passwords, and intentionally does not claim legal, clinical, privacy, security, or regulatory certification. Do not enter real patient data or use it to make treatment decisions. Before live use, the hospital must complete clinical workflow review, legal/compliance review for its jurisdiction, security design and penetration testing, data-protection impact assessment as applicable, validated backups/disaster recovery, integration testing, and formal acceptance testing with the clinical champion and senior embryologist.

## What is included

### Public frontend
- Responsive Alka IVF landing page, treatments, journey explainer, care-team sections, education resources and FAQs.
- Appointment-request modal with validation and an API-backed request reference.
- Clear language that appointment requests need clinic confirmation; no invented success-rate claims or treatment guarantees.
- Accessibility-aware navigation, visible focus, semantic labels, reduced-motion handling and mobile layouts.

### Patient portal (demo authentication)
- Patient-only portal endpoints for the signed-in patient's own appointments, cycles and invoices.
- Treatment stage timeline, upcoming visits and billing summary.
- Portal uses synthetic seed data. Phone OTP, biometrics, report downloads, secure chat, telemedicine, push/SMS/email/WhatsApp and legal e-signature integrations are not connected.

### Staff workspace
- Role-sensitive navigation and screens for overview, patient registry, appointments, IVF cycle states, lab/cryo inventory, consents, stock, billing, reporting, audit log and configuration status.
- API checks permissions on the server; frontend hiding is not the security boundary.
- Patient registration, appointment status changes, invoice creation, stock adjustments and consent status updates write audit events.
- Cycle state machine rejects invalid transitions; a trigger event requires an exact timestamp; critical steps require valid consent for each linked partner.
- Lab identity verification requires a matching material code/patient barcode plus password re-authentication by a different authorised staff member. A deliberate mismatch is recorded and blocked.
- Cryostorage release checks identity, consent, linked-partner conflicts and a second witness.

### Backend
- FastAPI REST API, SQLAlchemy data models and OpenAPI docs.
- SQLite for quick local development; set `DATABASE_URL` to PostgreSQL for a deployment-oriented environment.
- Password hashes use `scrypt`; staff/patient demo sessions use signed short-lived bearer tokens.
- Role and resource access checks, basic request validation, opaque UUID resource IDs and audit rows for sensitive reads/updates.
- Seeded fake data for a two-partner treatment unit, appointments, cycles, consent, lab material, inventory and invoices.

## Run locally (macOS / Linux)

Requirements: Python 3.11+ and Node.js 20+ with npm. On first run, package installation needs access to the Python package index and npm registry.

### Option A — two terminals

**Terminal 1 — backend**

```bash
cd alka-ivf-platform
./start-backend.sh
```

The API starts at `http://localhost:8000`. Interactive API documentation is at `http://localhost:8000/docs` and health check at `http://localhost:8000/api/v1/health`.

**Terminal 2 — frontend**

```bash
cd alka-ivf-platform
./start-frontend.sh
```

Open `http://localhost:5173`.

### Option B — Docker Compose

Requires Docker Desktop. From the project root:

```bash
docker compose up --build
```

Open `http://localhost:8080`; API docs are at `http://localhost:8000/docs`. Before using Compose anywhere shared, override `POSTGRES_PASSWORD` and `JWT_SECRET` with unique secrets. The supplied Compose values are local development defaults, not deployment secrets.

### Manual start

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app:app --reload --port 8000
```

In a second terminal:

```bash
cd frontend
npm install
npm run dev
```

For a non-default API URL, create `frontend/.env.local` based on `frontend/.env.example` and set `VITE_API_BASE_URL` before building.

## Demo accounts

All accounts below use the password `AlkaDemo!2026`:

| Purpose | Email | Permissions outline |
| --- | --- | --- |
| Hospital admin | `admin@alkaivf.demo` | Staff administration, operational modules, audit |
| Doctor | `doctor@alkaivf.demo` | Patients, appointments, cycles and consent workflows |
| Nurse | `nurse@alkaivf.demo` | Appointments and cycle workflow |
| Front desk | `reception@alkaivf.demo` | Patient registration and appointments |
| Embryologist | `embryologist@alkaivf.demo` | IVF cycles, lab/cryo, consent and inventory view |
| Accounts | `accounts@alkaivf.demo` | Billing and inventory adjustments |
| Compliance | `compliance@alkaivf.demo` | Consent, lab/cryo oversight, reports and audit |
| Patient portal | `patient@alkaivf.demo` | Only the linked synthetic patient's portal records |

The witness workflow can be tried from the admin/doctor workspace using second-witness account `embryologist@alkaivf.demo` and the demo password above. For the seeded records, try sample `OOC-2001` with patient barcode `P-AL-1001`; the deliberate mismatch `OOC-2001` with `P-AL-1002` must be blocked. Try cryo sample `CRYO-4020` to verify that the unconsented item is blocked.

## Core API routes

All business routes use prefix `/api/v1`.

| Route | Purpose | Access |
| --- | --- | --- |
| `POST /auth/login`, `GET /auth/me` | Demo sign-in and identity | Public login / authenticated identity |
| `GET /dashboard` | Operational counts | Staff roles only |
| `GET/POST /patients` | Patient registry | Admin, doctor, reception; selected read roles |
| `POST /appointments/public` | Public booking request | Public, rate limiting/CAPTCHA to add before launch |
| `GET /appointments`, `PATCH /appointments/{id}/status` | Scheduling and status | Staff roles by permission |
| `GET/POST /cycles`, `POST /cycles/{id}/events` | Cycle records and guarded state transitions | Clinical roles |
| `GET /lab/materials`, `POST /lab/witness` | Lab material and two-person witnessing | Lab/clinical authorised roles |
| `POST /cryo/release` | Consent-gated cryostorage release | Admin, embryology, compliance |
| `GET/PATCH /inventory` | Inventory list and adjustment | Role-limited |
| `GET/POST /invoices`, `GET /billing/patient-options` | Invoice list/create, minimal billing patient options | Accounts/admin |
| `GET/POST /consents`, `PATCH /consents/{id}/status` | Demo consent register and status | Admin, doctor, compliance |
| `GET /audit` | Recent audit events | Admin/compliance only |
| `GET /portal/me`, `/portal/appointments`, `/portal/cycles`, `/portal/invoices` | Own patient records only | Patient role |
| `GET /reports/summary` | Operational demo summary | Admin, doctor, accounts, compliance |

The full live schema is exposed through FastAPI's `/docs` page.

## Data storage and demo reset

Local backend data is stored in `backend/alka_ivf.db` and is ignored by Git. Stop the backend and delete that file to reset the SQLite demo database; the next startup seeds synthetic data again. Docker Compose stores PostgreSQL data in a named volume; `docker compose down -v` deletes that local volume irreversibly.

## Architecture notes and deliberate gaps

The project starts as a modular monolith with a documented REST API, consistent relational identifiers, and a separate front end. The PDF's production architecture calls for PostgreSQL, encrypted object storage, a managed identity provider with MFA/OTP, queue-backed notifications, in-country hosting, monitoring and a documented CI/CD process. This starter provides local substitutes to make development testable, but it does **not** claim those production guarantees.

Still required before real hospital operation:

1. Confirm the operating state/country, branch plan, ART/surrogacy applicability, PC-PNDT process, record-retention rules, approved consent wording, privacy notices and regulatory disclosures with qualified advisers.
2. Replace demo auth with a hardened OIDC provider, MFA for every staff member, patient OTP, session controls, break-glass approvals, rate limiting, CAPTCHA, CSRF strategy and abuse monitoring.
3. Add encryption-at-rest and key management, TLS termination, safe uploads and malware scanning, immutable/externally monitored audit retention, logs/alerts, monthly restore drills, disaster-recovery procedures and a penetration test.
4. Validate cycle protocols, timing semantics, medication safety, partner consent logic, witnessing, sample storage, freeze/thaw/release paths and downtime workflows with clinical and laboratory leads; develop comprehensive clinical scenario tests.
5. Connect and test payment gateways and signed webhooks, SMS/WhatsApp templates and opt-outs, email, video consultations, barcode/RFID readers, time-lapse incubators, tank sensors, lab devices, tax/accounting exports, and applicable FHIR/ABDM interfaces.
6. Build the remaining specification modules: full EMR/orders, follicle charts, prescriptions and interactions, imaging, complete LIMS, donor/surrogacy workflows where lawful, storage contracts/renewals, secure document/media storage, medication scheduling/escalation, messages, CMS, SEO content management, multi-language clinical translations, full pharmacy/procurement and staff training.
7. Do not enable success estimation, cycle-planning AI, embryo image-assist AI or other clinical decision support until data is validated, models are clinically reviewed, fairness and safety are assessed, and the clinician remains the decision-maker.
8. Complete load, accessibility, security, restore/failover and user acceptance testing. The PDF's target values (e.g. 99.9% uptime, typical API under 400 ms, 2.5 s page load and 500 concurrent users per branch) are targets, not measured results for this starter.

## Source requirements mapped

- PDF pages 3–6: end-to-end platform, role-based access, modular API-first architecture, data handling, accessibility and performance principles.
- Pages 8–13: phased roadmap, public website, patient portal and role-specific staff screens.
- Pages 14–20: security, patient/couple registry, scheduling, clinical records, cycle state machine, LIMS/cryo, consent, billing, notification, audit and API outline.
- Pages 21–24: patient journey companion, electronic witnessing, cryo vault, transparent cost planner, wellbeing, patient embryo updates, AI oversight and patient portability features.
- Pages 25–28: India-referenced regulatory topics, security controls, quality/testing goals, acceptance checklist and owner decisions.

The backend and screens are a practical foundation for the first development phase, not a claim that every one of those modules has been implemented.
