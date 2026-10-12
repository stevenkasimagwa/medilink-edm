# MediLink Enterprise Data Management Project

MediLink is an enterprise data management solution designed for Mulago Hospital. This repository contains the complete coursework deliverables, including the data strategy, governance framework, database scripts, data quality controls, master data management, warehouse and ETL design, metadata, security, analytics, automation, and supporting documentation.

## Repository structure

The work is organised by project phase:

| Phase | Focus | Key files |
| --- | --- | --- |
| 0 | Data sources and database setup | [`database creation.sql`](./Phase%200/database%20creation.sql), [`Data Sources for Mulago Hospital.pdf`](./Phase%200/Data%20Sources%20for%20Mulago%20Hospital.pdf) |
| 1 | Data lifecycle management | [`data_lifecycle.sql`](./Phase%201/data_lifecycle.sql), [`data lifecyle map.pdf`](./Phase%201/data%20lifecyle%20map.pdf) |
| 2 | Data governance | [`data_governance.sql`](./Phase%202/data_governance.sql), [`Governance Framework.pdf`](./Phase%202/Governance%20Framework.pdf) |
| 3 | Enterprise architecture and schema | [`schema.sql`](./Phase%203/schema.sql), [`medilink ERD.png`](./Phase%203/medilink%20ERD.png), [`medilink Architecture.png`](./Phase%203/medilink%20Architecture.png) |
| 4 | Data quality and monitoring | [`data_quality.sql`](./Phase%204/data_quality.sql), [`Data Quality Report.pdf`](./Phase%204/Data%20Quality%20Report.pdf) |
| 5 | Master data management | [`master_data_management.sql`](./Phase%205/master_data_management.sql), [`Master Data Management Plan.pdf`](./Phase%205/Master%20Data%20Management%20Plan.pdf) |
| 6 | Data warehouse and ETL | [`data_warehouse.sql`](./Phase%206/data_warehouse.sql), [`ETL Workflow.pdf`](./Phase%206/ETL%20Workflow.pdf) |
| 7 | Metadata and impact analysis | [`metadata.sql`](./Phase%207/metadata.sql), [`Catalog & Impact Analysis.pdf`](./Phase%207/Catalog%20%26%20Impact%20Analysis.pdf) |
| 8 | Compliance, privacy, and security | [`security.sql`](./Phase%208/security.sql), [`Compliance Audit Report & DPIA.pdf`](./Phase%208/Compliance%20Audit%20Report%20%26%20DPIA.pdf) |
| 9 | Analytics and management reporting | [`analytics.sql`](./Phase%209/analytics.sql), [`Management Findings.pdf`](./Phase%209/Management%20Findings.pdf), [`PowerBI Dashboard`](./Phase%209/PowerBI%20Dashboard/) |
| 10 | Operational automation | [`automation.sql`](./Phase%2010/automation.sql) |

The [`Project Final EDM Strategy Document`](./Project%20Final%20EDM%20Strategy%20Document/) contains the consolidated final strategy document. [`AllSqlCodeMedilink.sql`](./AllSqlCodeMedilink.sql) provides the combined SQL implementation.

## Getting started

1. Review the final strategy document for the overall architecture and implementation approach.
2. Run the SQL scripts in phase order against the target relational database.
3. Use the phase-specific reports and diagrams to validate governance, quality, security, and warehouse decisions.
4. Open the Power BI dashboard file in Power BI Desktop for the analytics deliverable.

## Project status

The repository contains the completed Enterprise Data Management coursework deliverables for the MediLink solution.