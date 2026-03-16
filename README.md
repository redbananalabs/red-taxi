# Red Taxi Platform

Multi-tenant taxi dispatch SaaS platform.

## Overview

Red Taxi is a ground-up rebuild of legacy taxi dispatch systems, designed as a scalable multi-tenant SaaS platform. It handles the complete taxi operations lifecycle: booking, dispatch, driver management, pricing, payments, messaging, and reporting.

## Repository Structure

```
/docs           - All project documentation (PRD, architecture, features)
/src            - Source code (coming soon)
```

## Documentation

All documentation lives in `/docs`. See [docs/README.md](docs/README.md) for the full documentation index.

Key documents:
- [Product Vision](docs/prd/product-vision.md)
- [System Overview](docs/architecture/system-overview.md)
- [Data Model](docs/data-model/README.md)
- [API Reference](docs/api/README.md)

## Tech Stack

- **Runtime**: .NET 8
- **API**: ASP.NET Core Minimal APIs
- **Database**: SQL Server / Azure SQL
- **Cache**: Redis
- **Real-time**: SignalR
- **Architecture**: Clean Architecture + MediatR

## Quick Links

- [Changelog](docs/changelog.md)
- [Decision Log](docs/decision-log.md)
- [Roadmap](docs/prd/roadmap.md)

## License

Proprietary - Red Banana Labs
